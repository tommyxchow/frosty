package com.tommychow.frosty.streamproxy

import org.json.JSONArray
import org.json.JSONObject

object StreamProxyPageScript {
    fun create(config: StreamProxyConfig): String {
        val workerInstaller = INSTALLER.replace("__INSTALLER_SOURCE__", "null")
        val pageInstaller = INSTALLER.replace(
            "__INSTALLER_SOURCE__",
            JSONObject.quote(workerInstaller),
        )
        return "($pageInstaller)(${config.toPageJson()});"
    }

    fun updateConfigScript(config: StreamProxyConfig): String {
        return "globalThis.__frostyStreamProxy?.updateConfig(${config.toPageJson()});"
    }

    private fun StreamProxyConfig.toPageJson(): String {
        return JSONObject()
            .put("enabled", enabled)
            .put("currentChannelLogin", currentChannelLogin)
            .put("hasProxyUrls", proxyUrls.isNotEmpty())
            .put("whitelistedChannels", JSONArray(whitelistedChannels.toList()))
            .put("debugLogging", debugLogging)
            .toString()
    }

    private val INSTALLER = """
function(initialConfig) {
  "use strict";

  const ACCEPT_FLAG = "TTV-LOL-PRO";
  const GRAPHQL_URL = "https://gql.twitch.tv/gql";
  const TWITCH_CLIENT_ID = "kimne78kx3ncx6brgo4mv6wki5h1ko";
  const scope = typeof WorkerGlobalScope !== "undefined" && self instanceof WorkerGlobalScope
    ? "worker"
    : "page";

  if (globalThis.__frostyStreamProxy) {
    globalThis.__frostyStreamProxy.updateConfig(initialConfig);
    return;
  }

  const nativeFetch = globalThis.fetch.bind(globalThis);
  const nativeWorker = scope === "page" ? globalThis.Worker : null;
  const state = {
    config: normalizeConfig(initialConfig),
    cachedUsherUrl: null,
    cachedPlaybackTokenRequestBody: null,
    cachedPlaybackTokenRequestHeaders: null,
    manifests: [],
    proxiedVideoWeaverUrls: new Map(),
    videoWeaverUrlsToNotProxy: new Set(),
    locks: new Map(),
    workerBlobUrls: [],
  };

  globalThis.__frostyStreamProxy = {
    updateConfig(config) {
      state.config = normalizeConfig(config);
      log("config updated");
    },
  };

  globalThis.fetch = streamProxyFetch;
  if (scope === "page" && nativeWorker) {
    installWorkerWrapper();
  }

  log("fetch hook installed in " + scope);

  async function streamProxyFetch(input, init) {
    const originalRequest = toRequest(input, init);
    const url = normalizeUrl(originalRequest.url);
    const host = hostFromUrl(url);
    let request = originalRequest;
    let requestType = null;
    let flagged = false;
    let response;

    try {
      if (!state.config.enabled) {
        return nativeFetch(request);
      }

      if (host === "gql.twitch.tv") {
        requestType = "graphQL";
        request = await handleGraphQlRequest(request);
      } else if (host === "usher.ttvnw.net") {
        requestType = "usher";
        const usherRequest = handleUsherRequest(request, url);
        request = usherRequest.request;
        flagged = usherRequest.flagged;
      } else if (isVideoWeaverHost(host)) {
        requestType = "videoWeaver";
        const weaverRequest = handleVideoWeaverRequest(request, url);
        request = weaverRequest.request;
        flagged = weaverRequest.flagged;
      }

      if (flagged && requestType) {
        response = await withTypeLock(requestType, () => nativeFetch(request));
      } else {
        if (requestType) {
          await waitForTypeLock(requestType);
        }
        response = await nativeFetch(request);
      }

      if (host === "usher.ttvnw.net" && response.status < 400) {
        await handleUsherResponse(response, url);
      } else if (isVideoWeaverHost(host) && response.status < 400) {
        await handleVideoWeaverResponse(response, url, flagged);
      }

      return response;
    } catch (error) {
      log("fetch hook error type=" + (requestType || "unknown") + " reason=" + formatError(error));
      throw error;
    }
  }

  async function handleGraphQlRequest(request) {
    const body = await request.clone().text().catch(() => null);
    if (!body || body.indexOf("PlaybackAccessToken") === -1) {
      return request;
    }

    state.cachedPlaybackTokenRequestBody = body;
    state.cachedPlaybackTokenRequestHeaders = headersToObject(request.headers);

    let parsed;
    try {
      parsed = JSON.parse(body);
    } catch (error) {
      log("graphQL parse failed reason=" + formatError(error));
      return request;
    }

    const queries = Array.isArray(parsed) ? parsed : [parsed];
    const eligible = queries.some((query) => {
      const login = query && query.variables && query.variables.login;
      if (!login || isVodLogin(login)) return false;
      if (query.variables.playerType === "frontpage") return false;
      return !isWhitelisted(login);
    });
    if (!eligible) {
      log("graphQL playback token skipped reason=ineligible");
      return request;
    }

    const headers = new Headers(request.headers);
    setHeaderIfExists(headers, "Authorization", "undefined");
    setHeaderIfExists(headers, "Client-Session-Id", randomString(16, "abcdefghijklmnopqrstuvwxyz0123456789"));
    setHeaderIfExists(headers, "Device-ID", randomString(32));
    setHeaderIfExists(headers, "X-Device-Id", randomString(32));
    log("graphQL playback token anonymized");
    return new Request(request, { headers });
  }

  function handleUsherRequest(request, url) {
    state.cachedUsherUrl = url;
    const channel = channelFromUsherUrl(url);
    if (url.toLowerCase().indexOf("/vod/") !== -1) {
      log("usher skipped channel=" + (channel || "") + " reason=vod");
      return { request, flagged: false };
    }
    if (url.indexOf(encodeURIComponent('"player_type":"frontpage"')) !== -1) {
      log("usher skipped channel=" + (channel || "") + " reason=frontpage");
      return { request, flagged: false };
    }
    if (isWhitelisted(channel)) {
      log("usher skipped channel=" + (channel || "") + " reason=whitelisted");
      return { request, flagged: false };
    }

    let nextRequest = request;
    const anonymizedUrl = anonymizeUsherUrl(url);
    if (anonymizedUrl !== url) {
      nextRequest = new Request(anonymizedUrl, request);
    }

    if (!state.config.hasProxyUrls) {
      return { request: nextRequest, flagged: false };
    }

    log("usher flagged channel=" + (channel || ""));
    return { request: flagRequest(nextRequest), flagged: true };
  }

  function handleVideoWeaverRequest(request, url) {
    if (state.videoWeaverUrlsToNotProxy.has(url)) {
      log("videoWeaver skipped reason=marked_direct");
      return { request, flagged: false };
    }

    const manifest = findManifestForUrl(url);
    let videoWeaverUrl = url;
    if (manifest && manifest.replacementMap) {
      const quality = qualityForUrl(manifest.assignedMap, url);
      videoWeaverUrl = quality && manifest.replacementMap.has(quality)
        ? manifest.replacementMap.get(quality)
        : firstMapValue(manifest.replacementMap);
      if (videoWeaverUrl && videoWeaverUrl !== url) {
        request = new Request(videoWeaverUrl, request);
        log("videoWeaver replaced quality=" + (quality || "fallback"));
      }
    }

    if (!state.config.hasProxyUrls || !isVideoWeaverPlaylistUrl(videoWeaverUrl)) {
      return { request, flagged: false };
    }

    const count = state.proxiedVideoWeaverUrls.get(videoWeaverUrl) || 0;
    if (count >= 1) {
      return { request, flagged: false };
    }

    state.proxiedVideoWeaverUrls.set(videoWeaverUrl, count + 1);
    log("videoWeaver flagged count=" + (count + 1));
    return { request: flagRequest(request), flagged: true };
  }

  async function handleUsherResponse(response, url) {
    if (url.toLowerCase().indexOf("/vod/") !== -1) return;
    const body = await response.clone().text().catch(() => null);
    if (!body) return;

    const channel = channelFromUsherUrl(url);
    const assignedMap = parseUsherManifest(body, url);
    if (!assignedMap || assignedMap.size === 0) {
      log("usher response parse failed channel=" + (channel || ""));
      return;
    }

    state.manifests = state.manifests.filter((manifest) => !manifest.deleted);
    const manifest = {
      channelName: channel,
      assignedMap,
      replacementMap: null,
      consecutiveAdResponses: 0,
      consecutiveAdCooldown: 0,
      deleted: false,
    };
    state.manifests.push(manifest);

    for (const videoWeaverUrl of assignedMap.values()) {
      state.proxiedVideoWeaverUrls.delete(videoWeaverUrl);
      state.videoWeaverUrlsToNotProxy.delete(videoWeaverUrl);
      if (url.indexOf(encodeURIComponent('"player_type":"frontpage"')) !== -1 || isWhitelisted(channel)) {
        state.videoWeaverUrlsToNotProxy.add(videoWeaverUrl);
      }
    }
    log("usher response tracked channel=" + (channel || "") + " variants=" + assignedMap.size);
  }

  async function handleVideoWeaverResponse(response, url, flagged) {
    const manifest = findManifestForUrl(url);
    if (!manifest) return;

    const body = await response.clone().text().catch(() => null);
    if (!body) return;

    const includesAd = body.toLowerCase().indexOf("stitched-ad") !== -1;
    if (!includesAd) {
      if (manifest.consecutiveAdCooldown > 0) {
        manifest.consecutiveAdCooldown -= 1;
      } else {
        manifest.consecutiveAdResponses = 0;
      }
      return;
    }

    log("videoWeaver ad_detected channel=" + (manifest.channelName || ""));
    if (state.videoWeaverUrlsToNotProxy.has(url)) return;

    manifest.consecutiveAdResponses += 1;
    manifest.consecutiveAdCooldown = 15;
    if (manifest.consecutiveAdResponses <= 1) {
      const replacementUrls = await updateVideoWeaverReplacementMap(manifest, flagged ? false : undefined);
      if (flagged) {
        replacementUrls.forEach((replacementUrl) => state.videoWeaverUrlsToNotProxy.add(replacementUrl));
      }
      log("videoWeaver replacement_ready count=" + replacementUrls.length);
      throw new Error("Frosty stream proxy cancelled ad playlist request");
    }

    if (manifest.consecutiveAdResponses === 2 && manifest.replacementMap && !flagged) {
      manifest.replacementMap = null;
      throw new Error("Frosty stream proxy reset replacement map");
    }
  }

  async function updateVideoWeaverReplacementMap(manifest, flaggedOverride) {
    const token = await fetchReplacementPlaybackAccessToken(flaggedOverride);
    if (!token || !token.value || !token.signature) {
      throw new Error("replacement token unavailable");
    }

    const usherManifest = await fetchReplacementUsherManifest(token, flaggedOverride);
    const replacementMap = parseUsherManifest(usherManifest || "", state.cachedUsherUrl || "");
    if (!replacementMap || replacementMap.size === 0) {
      throw new Error("replacement usher parse failed");
    }

    manifest.replacementMap = replacementMap;
    return Array.from(replacementMap.values());
  }

  async function fetchReplacementPlaybackAccessToken(flaggedOverride) {
    const channel = state.config.currentChannelLogin;
    if (!channel) return null;

    const headers = new Headers();
    headers.set("Authorization", "undefined");
    headers.set("Client-ID", TWITCH_CLIENT_ID);
    headers.set("Content-Type", "text/plain; charset=UTF-8");
    headers.set("Device-ID", randomString(32));

    const queryText = "query PlaybackAccessToken_Template { streamPlaybackAccessToken(channelName: " +
      JSON.stringify(channel) +
      ", params: {platform: \"web\", playerBackend: \"mediaplayer\", playerType: \"site\"}) { value signature authorization { isForbidden forbiddenReasonCode } __typename }}";
    const query = {
      operationName: "PlaybackAccessToken_Template",
      query: queryText,
      variables: {},
    };

    let request = new Request(GRAPHQL_URL, {
      method: "POST",
      headers,
      body: JSON.stringify(query),
    });
    if (flaggedOverride === true && state.config.hasProxyUrls) {
      request = flagRequest(request);
    }

    const response = await nativeFetch(request);
    if (response.status >= 400) return null;
    const json = await response.json();
    return json && json.data && json.data.streamPlaybackAccessToken;
  }

  async function fetchReplacementUsherManifest(token, flaggedOverride) {
    const replacementUrl = getReplacementUsherUrl(token);
    if (!replacementUrl) return null;

    let request = new Request(replacementUrl);
    const shouldFlag = flaggedOverride === undefined ? state.config.hasProxyUrls : flaggedOverride;
    if (shouldFlag && state.config.hasProxyUrls) {
      request = flagRequest(request);
    }

    const response = await nativeFetch(request);
    if (response.status >= 400) return null;
    return response.text();
  }

  function getReplacementUsherUrl(token) {
    if (!state.cachedUsherUrl) return null;
    try {
      const url = new URL(state.cachedUsherUrl);
      url.searchParams.set("sig", token.signature);
      url.searchParams.set("token", token.value);
      return anonymizeUsherUrl(url.toString());
    } catch (error) {
      return null;
    }
  }

  function parseUsherManifest(body, manifestUrl) {
    const lines = body.split(/\r?\n/).map((line) => line.trim());
    const variants = [];
    let pendingAttributes = null;

    for (const line of lines) {
      if (!line) continue;
      if (line.toUpperCase().indexOf("#EXT-X-STREAM-INF:") === 0) {
        pendingAttributes = parseAttributes(line.substring(line.indexOf(":") + 1));
        continue;
      }
      if (line.charAt(0) === "#") continue;
      if (!pendingAttributes) continue;

      variants.push({
        attributes: pendingAttributes,
        uri: absolutize(line, manifestUrl),
      });
      pendingAttributes = null;
    }

    if (variants.length === 0) return null;

    variants.sort((a, b) => {
      const scoreA = Number(a.attributes.SCORE || 0);
      const scoreB = Number(b.attributes.SCORE || 0);
      if (scoreA && scoreB) return scoreB - scoreA;
      return b.uri.length - a.uri.length;
    });

    const keys = new Map();
    const map = new Map();
    variants.forEach((variant, index) => {
      const resolution = variant.attributes.RESOLUTION || "";
      const height = resolution.indexOf("x") !== -1 ? resolution.split("x")[1] : "";
      const frameRate = variant.attributes["FRAME-RATE"] ? Math.round(Number(variant.attributes["FRAME-RATE"])) : "";
      const baseKey = height ? height + "p" + frameRate : "idx_" + index;
      const count = keys.get(baseKey) || 0;
      keys.set(baseKey, count + 1);
      map.set(count === 0 ? baseKey : baseKey + "_" + count, variant.uri);
    });
    return map;
  }

  function parseAttributes(raw) {
    const attributes = {};
    let key = "";
    let value = "";
    let readingKey = true;
    let quoted = false;

    function commit() {
      if (key) attributes[key.trim()] = value.trim().replace(/^"|"$/g, "");
      key = "";
      value = "";
      readingKey = true;
    }

    for (let i = 0; i < raw.length; i += 1) {
      const char = raw.charAt(i);
      if (readingKey && char === "=") {
        readingKey = false;
        continue;
      }
      if (!readingKey && char === '"') {
        quoted = !quoted;
      }
      if (!readingKey && char === "," && !quoted) {
        commit();
        continue;
      }
      if (readingKey) key += char;
      else value += char;
    }
    commit();
    return attributes;
  }

  function installWorkerWrapper() {
    globalThis.Worker = class FrostyStreamProxyWorker extends nativeWorker {
      constructor(scriptUrl, options) {
        const fullUrl = absolutize(String(scriptUrl), String(location.href));
        if (fullUrl.indexOf(".twitch.tv") === -1) {
          super(scriptUrl, options);
          return;
        }

        let twitchWorkerScript = "";
        try {
          const request = new XMLHttpRequest();
          request.open("GET", fullUrl, false);
          request.send();
          if (request.status >= 200 && request.status < 300) {
            twitchWorkerScript = request.responseText;
          } else {
            twitchWorkerScript = "importScripts(" + JSON.stringify(fullUrl) + ");";
          }
        } catch (error) {
          twitchWorkerScript = "importScripts(" + JSON.stringify(fullUrl) + ");";
        }

        const workerInstallerSource = __INSTALLER_SOURCE__;
        if (!workerInstallerSource) {
          super(scriptUrl, options);
          return;
        }

        const workerScript = "(" + workerInstallerSource + ")(" + JSON.stringify(state.config) + ");\n" + twitchWorkerScript;
        const blobUrl = URL.createObjectURL(new Blob([workerScript], { type: "text/javascript" }));
        state.workerBlobUrls.push(blobUrl);
        super(blobUrl, options);
      }
    };
    log("Worker hook installed");
  }

  function toRequest(input, init) {
    return input instanceof Request ? new Request(input, init) : new Request(input, init);
  }

  function normalizeUrl(url) {
    return absolutize(url, String(location.href));
  }

  function absolutize(url, base) {
    try {
      return new URL(url, base).toString();
    } catch (error) {
      return url;
    }
  }

  function hostFromUrl(url) {
    try {
      return new URL(url).host.toLowerCase();
    } catch (error) {
      return "";
    }
  }

  function channelFromUsherUrl(url) {
    const match = /\/hls\/([^/?#]+)\.m3u8/i.exec(url);
    return match ? decodeURIComponent(match[1]).toLowerCase() : null;
  }

  function isVideoWeaverHost(host) {
    return /^(?:[a-z0-9-]+\.playlist\.(?:live-video|ttvnw)\.net|video-weaver\.[a-z0-9-]+\.hls\.ttvnw\.net)$/i.test(host);
  }

  function isVideoWeaverPlaylistUrl(url) {
    return /^https?:\/\/(?:[a-z0-9-]+\.playlist\.(?:live-video|ttvnw)\.net|video-weaver\.[a-z0-9-]+\.hls\.ttvnw\.net)\/v1\/playlist\/.+\.m3u8(?:$|[?#])/i.test(url);
  }

  function isVodLogin(login) {
    return /^\d+$/.test(String(login));
  }

  function isWhitelisted(channel) {
    if (!channel) return false;
    return state.config.whitelistedChannels.indexOf(String(channel).toLowerCase()) !== -1;
  }

  function flagRequest(request) {
    const headers = new Headers(request.headers);
    const accept = headers.get("Accept") || "";
    if (accept.indexOf(ACCEPT_FLAG) === -1) {
      headers.set("Accept", accept + ACCEPT_FLAG);
    }
    return new Request(request, { headers });
  }

  function anonymizeUsherUrl(rawUrl) {
    try {
      const url = new URL(rawUrl);
      url.searchParams.set("p", String(Math.floor(Math.random() * 10000000)));
      url.searchParams.set("play_session_id", randomString(32, "abcdefghijklmnopqrstuvwxyz0123456789"));
      return url.toString();
    } catch (error) {
      return rawUrl;
    }
  }

  function findManifestForUrl(url) {
    for (const manifest of state.manifests) {
      for (const assignedUrl of manifest.assignedMap.values()) {
        if (assignedUrl === url) return manifest;
      }
    }
    return null;
  }

  function qualityForUrl(map, url) {
    for (const entry of map.entries()) {
      if (entry[1] === url) return entry[0];
    }
    return null;
  }

  function firstMapValue(map) {
    const next = map.values().next();
    return next.done ? null : next.value;
  }

  function setHeaderIfExists(headers, name, value) {
    if (headers.has(name)) headers.set(name, value);
  }

  function headersToObject(headers) {
    const object = {};
    headers.forEach((value, key) => {
      object[key] = value;
    });
    return object;
  }

  function normalizeConfig(config) {
    const whitelistedChannels = Array.isArray(config && config.whitelistedChannels)
      ? config.whitelistedChannels.map((channel) => String(channel).toLowerCase())
      : [];
    return {
      enabled: !!(config && config.enabled),
      currentChannelLogin: String((config && config.currentChannelLogin) || "").toLowerCase(),
      hasProxyUrls: !!(config && config.hasProxyUrls),
      whitelistedChannels,
      debugLogging: !!(config && config.debugLogging),
    };
  }

  function randomString(length, alphabet) {
    const chars = alphabet || "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    let result = "";
    const cryptoObject = globalThis.crypto;
    if (cryptoObject && cryptoObject.getRandomValues) {
      const bytes = new Uint8Array(length);
      cryptoObject.getRandomValues(bytes);
      for (let i = 0; i < length; i += 1) {
        result += chars.charAt(bytes[i] % chars.length);
      }
      return result;
    }
    for (let i = 0; i < length; i += 1) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  async function withTypeLock(type, task) {
    const previous = state.locks.get(type) || Promise.resolve();
    let release;
    const next = new Promise((resolve) => {
      release = resolve;
    });
    state.locks.set(type, previous.catch(() => undefined).then(() => next));
    await previous.catch(() => undefined);
    try {
      return await task();
    } finally {
      release();
    }
  }

  async function waitForTypeLock(type) {
    const lock = state.locks.get(type);
    if (lock) await lock.catch(() => undefined);
  }

  function formatError(error) {
    if (!error) return "unknown";
    return error.message || String(error);
  }

  function log(message) {
    if (state.config.debugLogging) {
      console.log("[FrostyStreamProxy] " + message);
    }
  }
}
"""
}
