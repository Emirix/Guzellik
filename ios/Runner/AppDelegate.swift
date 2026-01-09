import Flutter
import UIKit
import GoogleMaps
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDKjhVYa0okqPZFJcQyXK4x57iIV9JWAFE")
    GeneratedPluginRegistrant.register(with: self)
    
    // Native Ad Factory kaydet
    let listTileFactory = ListTileNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "listTile", nativeAdFactory: listTileFactory)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
