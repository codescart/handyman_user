import UIKit
import Flutter
import GoogleMaps
import Braintree

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      GMSServices.provideAPIKey("AIzaSyCHJwjZjGSOBc18-3mJM8tCqDYoV3Nk9tQ")
      BTAppContextSwitcher.setReturnURLScheme("com.iqonic.user.payments")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "com.iqonic.user.payments" {
            return BTAppContextSwitcher.handleOpenURL(url)
        }
            
        return false
    }
}
