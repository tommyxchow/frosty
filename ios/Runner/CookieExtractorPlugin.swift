import Flutter
import WebKit

class CookieExtractorPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "frosty/cookie_extractor",
            binaryMessenger: registrar.messenger()
        )
        let instance = CookieExtractorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "extractTwitchAuthToken" {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                let authCookie = cookies.first {
                    $0.name == "auth-token" && $0.domain.contains("twitch.tv")
                }
                result(authCookie?.value)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
