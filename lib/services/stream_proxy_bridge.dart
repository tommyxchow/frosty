import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frosty/services/stream_proxy_config.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class StreamProxyBridge {
  static const _channel = MethodChannel('frosty/stream_proxy');

  void Function(String url)? _onPageFinished;
  int? _webViewIdentifier;

  StreamProxyBridge() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  bool get isSupported => Platform.isAndroid;

  Future<void> attach({
    required AndroidWebViewController controller,
    required StreamProxyConfig config,
    required void Function(String url) onPageFinished,
  }) async {
    if (!isSupported) return;

    _onPageFinished = onPageFinished;
    _webViewIdentifier = controller.webViewIdentifier;

    await _invoke('attach', {
      'webViewIdentifier': _webViewIdentifier,
      'config': config.toMethodChannelPayload(),
    });
  }

  Future<void> updateConfig(StreamProxyConfig config) async {
    if (!isSupported) return;

    await _invoke('updateConfig', {
      'webViewIdentifier': _webViewIdentifier,
      'config': config.toMethodChannelPayload(),
    });
  }

  Future<void> detach(AndroidWebViewController controller) async {
    if (!isSupported) return;

    await _invoke('detach', {
      'webViewIdentifier': controller.webViewIdentifier,
    });
    _onPageFinished = null;
    _webViewIdentifier = null;
  }

  void dispose() {
    _onPageFinished = null;
    _webViewIdentifier = null;
    _channel.setMethodCallHandler(null);
  }

  Future<void> _invoke(String method, Map<String, Object?> arguments) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on PlatformException catch (e) {
      debugPrint('Stream proxy bridge $method failed: ${e.message}');
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pageFinished':
        final arguments = call.arguments;
        if (arguments is Map) {
          final url = arguments['url'];
          if (url is String) {
            _onPageFinished?.call(url);
          }
        }
        return;
      default:
        debugPrint('Unknown stream proxy bridge method: ${call.method}');
    }
  }
}
