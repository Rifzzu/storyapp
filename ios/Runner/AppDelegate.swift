import Flutter
import UIKit
import GoogleMaps 

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    GMSServices.provideAPIKey("AIzaSyCZ2B_U9XSHTFMBAjsVTE1kYyiAz_UKPFA")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
