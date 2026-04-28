import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    guard let cookieExtractorRegistrar = self.registrar(
      forPlugin: "CookieExtractorPlugin"
    ) else {
      assertionFailure("Failed to create CookieExtractorPlugin registrar")
      return false
    }
    CookieExtractorPlugin.register(with: cookieExtractorRegistrar)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
