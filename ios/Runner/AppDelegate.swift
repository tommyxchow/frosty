import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    CookieExtractorPlugin.register(with: self.registrar(forPlugin: "CookieExtractorPlugin")!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
