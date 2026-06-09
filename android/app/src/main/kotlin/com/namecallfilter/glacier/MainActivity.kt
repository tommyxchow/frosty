package com.namecallfilter.glacier

import cl.puntito.simple_pip_mode.PipCallbackHelperActivityWrapper
import com.namecallfilter.glacier.streamproxy.StreamProxyChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: PipCallbackHelperActivityWrapper() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        StreamProxyChannel.register(flutterEngine)
    }
}
