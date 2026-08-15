import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let cookieExtractorRegistrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "CookieExtractorPlugin"
    ) else {
      assertionFailure("Failed to create CookieExtractorPlugin registrar")
      return
    }
    CookieExtractorPlugin.register(with: cookieExtractorRegistrar)
  }
}

