import 'package:flutter/foundation.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';

class StreamProxyConfig {
  final StreamProxyMode mode;
  final String currentChannelLogin;
  final List<String> proxyUrls;
  final List<String> whitelistedChannels;
  final bool debugLogging;

  const StreamProxyConfig({
    required this.mode,
    required this.currentChannelLogin,
    required this.proxyUrls,
    required this.whitelistedChannels,
    this.debugLogging = kDebugMode,
  });

  factory StreamProxyConfig.fromSettings({
    required SettingsStore settingsStore,
    required String currentChannelLogin,
    bool debugLogging = kDebugMode,
  }) {
    return StreamProxyConfig(
      mode: settingsStore.streamProxyMode,
      currentChannelLogin: currentChannelLogin,
      proxyUrls: settingsStore.streamProxyUrls,
      whitelistedChannels: settingsStore.streamProxyWhitelistedChannels,
      debugLogging: debugLogging,
    );
  }

  Map<String, Object?> toMethodChannelPayload() {
    return {
      'mode': mode.name,
      'currentChannelLogin': currentChannelLogin.trim().toLowerCase(),
      'proxyUrls': proxyUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList(),
      'whitelistedChannels': whitelistedChannels
          .map((channel) => channel.trim().toLowerCase())
          .where((channel) => channel.isNotEmpty)
          .toList(),
      'debugLogging': debugLogging,
    };
  }
}

String? validateStreamProxyUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 'Enter a proxy URL';
  }

  final normalized = trimmed.contains('://') ? trimmed : 'http://$trimmed';
  final explicitPort = _extractExplicitPort(normalized);
  if (explicitPort == null) {
    return 'Enter a proxy port';
  }

  final port = int.tryParse(explicitPort);
  if (port == null) {
    return 'Enter a numeric proxy port';
  }

  final Uri uri;
  try {
    uri = Uri.parse(normalized);
  } catch (_) {
    return 'Enter a valid proxy URL';
  }

  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return 'Use an HTTP or HTTPS proxy';
  }

  if (uri.host.isEmpty) {
    return 'Enter a proxy host';
  }

  if (port <= 0 || port > 65535) {
    return 'Enter a proxy port';
  }

  return null;
}

String? _extractExplicitPort(String normalizedUrl) {
  final schemeSeparatorIndex = normalizedUrl.indexOf('://');
  if (schemeSeparatorIndex == -1) {
    return null;
  }

  final authorityStart = schemeSeparatorIndex + 3;
  final authorityEnd = normalizedUrl.indexOf(
    RegExp(r'[/#?]'),
    authorityStart,
  );
  final authority = normalizedUrl.substring(
    authorityStart,
    authorityEnd == -1 ? normalizedUrl.length : authorityEnd,
  );
  final hostAndPort = authority.substring(authority.lastIndexOf('@') + 1);

  if (hostAndPort.startsWith('[')) {
    final closingBracketIndex = hostAndPort.indexOf(']');
    if (closingBracketIndex == -1 ||
        closingBracketIndex + 1 >= hostAndPort.length ||
        hostAndPort[closingBracketIndex + 1] != ':') {
      return null;
    }

    return hostAndPort.substring(closingBracketIndex + 2);
  }

  final portSeparatorIndex = hostAndPort.lastIndexOf(':');
  if (portSeparatorIndex == -1 ||
      hostAndPort.indexOf(':') != portSeparatorIndex) {
    return null;
  }

  return hostAndPort.substring(portSeparatorIndex + 1);
}

String? validateStreamProxyChannelLogin(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 'Enter a channel login';
  }

  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
    return 'Use letters, numbers, and underscores only';
  }

  return null;
}
