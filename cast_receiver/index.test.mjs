import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const receiverHtml = fs.readFileSync(new URL('./index.html', import.meta.url), 'utf8');
const inlineScriptBody = receiverHtml.match(
	/<script>\s*\(\(\) => \{([\s\S]*)\}\)\(\);\s*<\/script>/,
)?.[1];

if (!inlineScriptBody) {
	throw new Error('Unable to find Cast receiver inline script');
}

const inlineScript = `(() => {${inlineScriptBody}})();`;

const createHarness = () => {
	let nowMs = 0;
	const intervals = [];
	const sentMessages = [];
	const consoleMessages = [];
	const messageListeners = new Map();
	const loadInterceptors = new Map();
	const seekCalls = [];
	const loadCalls = [];

	let liveRange = {start: 0, end: 0};
	let currentTimeSec = 0;
	let playerState = 'PLAYING';
	let playbackRate = 1.0;
	let playbackConfig = null;
	let receiverOptions = null;

	const playerManager = {
		getLiveSeekableRange: () => liveRange,
		getCurrentTimeSec: () => currentTimeSec,
		getPlayerState: () => playerState,
		getPlaybackRate: () => playbackRate,
		setPlaybackConfig: (config) => {
			playbackConfig = config;
		},
		setMessageInterceptor: (type, interceptor) => {
			loadInterceptors.set(type, interceptor);
		},
		seek: (request) => {
			seekCalls.push(request);
			currentTimeSec = request.currentTime;
		},
		load: (request) => {
			loadCalls.push(request);
			return Promise.resolve();
		},
	};

	const receiverContext = {
		getPlayerManager: () => playerManager,
		getSenders: () => [{id: 'sender-1'}],
		sendCustomMessage: (_namespace, _senderId, message) => {
			sentMessages.push(message);
		},
		addCustomMessageListener: (namespace, listener) => {
			messageListeners.set(namespace, listener);
		},
		start: (options) => {
			receiverOptions = options;
		},
	};

	const sandbox = {
		cast: {
			framework: {
				CastReceiverContext: {
					getInstance: () => receiverContext,
				},
				PlaybackConfig: function PlaybackConfig() {},
				CastReceiverOptions: function CastReceiverOptions() {},
				messages: {
					MessageType: {
						LOAD: 'LOAD',
					},
					ResumeState: {
						PLAYBACK_START: 'PLAYBACK_START',
					},
					StreamType: {
						LIVE: 'LIVE',
					},
				},
			},
		},
		console: {
			log: (message) => {
				consoleMessages.push(String(message));
			},
		},
		Date: {
			now: () => nowMs,
		},
		document: {
			querySelector: () => ({playbackRate}),
		},
		JSON,
		Math,
		Number,
		setInterval: (callback, delayMs) => {
			intervals.push({callback, delayMs});
			return intervals.length;
		},
	};

	vm.runInNewContext(inlineScript, sandbox);

	const runInterval = (delayMs) => {
		const interval = intervals.find((candidate) => candidate.delayMs === delayMs);
		if (!interval) {
			throw new Error(`Missing interval ${delayMs}`);
		}
		interval.callback();
	};

	const runLoadInterceptor = (loadRequestData) => {
		const interceptor = loadInterceptors.get('LOAD');
		if (!interceptor) {
			throw new Error('Missing LOAD interceptor');
		}
		return interceptor(loadRequestData);
	};

	return {
		get playbackConfig() {
			return playbackConfig;
		},
		get receiverOptions() {
			return receiverOptions;
		},
		sentMessages,
		consoleMessages,
		seekCalls,
		loadCalls,
		setLiveStatus({rangeStart = 0, rangeEnd, currentTime}) {
			liveRange = {start: rangeStart, end: rangeEnd};
			currentTimeSec = currentTime;
		},
		setPlayerState(nextState) {
			playerState = nextState;
		},
		advance(ms) {
			nowMs += ms;
		},
		runLatencyCheck() {
			runInterval(500);
		},
		runStatusReport() {
			runInterval(1000);
		},
		runLoadInterceptor,
	};
};

test('configures Shaka for stable low-latency live playback', () => {
	const harness = createHarness();

	assert.equal(harness.receiverOptions.useShakaForHls, true);
	assert.equal(harness.playbackConfig.shakaConfig.streaming.lowLatencyMode, true);
	assert.equal(harness.playbackConfig.shakaConfig.streaming.liveSync.enabled, true);
	assert.equal(harness.playbackConfig.shakaConfig.streaming.liveSync.targetLatency, 4.0);
	assert.equal(harness.playbackConfig.shakaConfig.streaming.liveSync.maxPlaybackRate, 1.1);
	assert.equal(harness.playbackConfig.shakaConfig.streaming.liveSync.minPlaybackRate, 0.98);
	assert.equal(harness.playbackConfig.shakaConfig.streaming.liveSync.panicMode, true);
	assert.equal(harness.playbackConfig.shakaConfig.streaming.liveSync.panicThreshold, 8.0);
	assert.equal(harness.playbackConfig.shakaConfig.manifest.defaultPresentationDelay, 4.0);
});

test('emergency latency bypasses normal seek cooldown', () => {
	const harness = createHarness();

	harness.setPlayerState('BUFFERING');
	harness.setLiveStatus({rangeEnd: 50, currentTime: 41});
	harness.runLatencyCheck();

	assert.equal(harness.seekCalls.length, 1);
	assert.equal(harness.seekCalls[0].currentTime, 46);

	harness.advance(1000);
	harness.setLiveStatus({rangeEnd: 52, currentTime: 41});
	harness.runLatencyCheck();

	assert.equal(harness.seekCalls.length, 2);
	assert.equal(harness.seekCalls[1].currentTime, 48);
	assert.ok(
		harness.consoleMessages.some((message) =>
			message.includes('action=max_latency') &&
				message.includes('latency_ms=11000') &&
				message.includes('emergency=true'),
		),
	);
});

test('reloads the current media after sustained emergency latency', () => {
	const harness = createHarness();
	const loadRequestData = {
		media: {
			contentId: 'http://127.0.0.1:4000/relay/source.m3u8',
		},
	};

	const interceptedLoad = harness.runLoadInterceptor(loadRequestData);

	harness.setPlayerState('BUFFERING');
	harness.setLiveStatus({rangeEnd: 100, currentTime: 80});
	harness.runLatencyCheck();

	assert.equal(harness.seekCalls.length, 1);

	for (let index = 0; index < 3; index += 1) {
		harness.advance(500);
		harness.setLiveStatus({rangeEnd: 100 + index + 1, currentTime: 80});
		harness.runLatencyCheck();
	}

	assert.equal(harness.loadCalls.length, 1);
	assert.equal(harness.loadCalls[0], interceptedLoad);
	assert.equal(harness.loadCalls[0].autoplay, true);
	assert.equal(harness.loadCalls[0].media.streamType, 'LIVE');
	assert.ok(
		harness.sentMessages.some((message) => message.correction === 'maxLatencyReload'),
	);
});

test('does not keep old custom stall recovery logic', () => {
	assert.equal(receiverHtml.includes('STALL_RECOVERY_'), false);
	assert.equal(receiverHtml.includes('isPlaybackStalled'), false);
	assert.equal(receiverHtml.includes('recoverStalledPlayback'), false);
	assert.equal(receiverHtml.includes('jumpToLiveWithCooldown'), false);
});
