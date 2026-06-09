package com.tommychow.frosty

import cl.puntito.simple_pip_mode.PipCallbackHelperActivityWrapper
import com.tommychow.frosty.streamproxy.StreamProxyChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: PipCallbackHelperActivityWrapper() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        StreamProxyChannel.register(flutterEngine)
    }
}
