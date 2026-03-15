package com.tommychow.frosty

import cl.puntito.simple_pip_mode.PipCallbackHelperActivityWrapper
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: PipCallbackHelperActivityWrapper() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(CookieExtractorPlugin())
    }
}
