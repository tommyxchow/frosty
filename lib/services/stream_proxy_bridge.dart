import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frosty/services/cast_state.dart';
import 'package:frosty/services/stream_proxy_config.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class StreamProxyBridge {
  static const _channel = MethodChannel('frosty/stream_proxy');
  static final castState = ValueNotifier<CastState>(
    const CastState.disconnected(),
  );
  static StreamProxyBridge? _activeBridge;
  static var _methodCallHandlerAttached = false;

  void Function(String url)? _onPageFinished;
  int? _webViewIdentifier;

  StreamProxyBridge() {
    _activeBridge = this;
    _ensureMethodCallHandler();
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

  Future<void> updateCastContext({
    required StreamProxyConfig config,
    required String title,
    String? subtitle,
    String? quality,
  }) async {
    if (!isSupported) return;
    final webViewIdentifier = _webViewIdentifier;
    if (webViewIdentifier == null) return;

    await _invoke('updateCastContext', {
      'webViewIdentifier': webViewIdentifier,
      'config': config.toMethodChannelPayload(),
      'title': title,
      'subtitle': subtitle,
      'quality': quality,
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
    if (identical(_activeBridge, this)) {
      _activeBridge = null;
    }
  }

  Future<void> _invoke(String method, Map<String, Object?> arguments) async {
    await _invokeStatic(method, arguments);
  }

  static Future<void> showCastDialog() async {
    if (!Platform.isAndroid) return;
    await _invokeStatic('showCastDialog', const {});
  }

  static Future<void> stopCasting() async {
    if (!Platform.isAndroid) return;
    await _invokeStatic('stopCasting', const {});
  }

  static Future<void> _invokeStatic(
    String method,
    Map<String, Object?> arguments,
  ) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on PlatformException catch (e) {
      debugPrint('Stream proxy bridge $method failed: ${e.message}');
    }
  }

  static void _ensureMethodCallHandler() {
    if (_methodCallHandlerAttached) return;

    _channel.setMethodCallHandler(_handleMethodCall);
    _methodCallHandlerAttached = true;
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pageFinished':
        final arguments = call.arguments;
        if (arguments is Map) {
          final url = arguments['url'];
          if (url is String) {
            _activeBridge?._onPageFinished?.call(url);
          }
        }
        return;
      case 'castStateChanged':
        castState.value = CastState.fromMethodChannelPayload(call.arguments);
        return;
      default:
        debugPrint('Unknown stream proxy bridge method: ${call.method}');
    }
  }
}
