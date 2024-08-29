import UIKit
import Flutter
import Firebase
import TMapSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, TMapTapiDelegate {
  let appKey:String = "l7xx9363c407318b4b04910193a57d19242a";

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "logis.flutter.iostmap",binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in

      switch (call.method) {
      case "initTmapAPI":
        self?.initTmapAPI()
        result("initTmapAPI")
        break;
      case "isTmapApplicationInstalled":
        if(TMapApi.isTmapApplicationInstalled()) {
          result("")
        }else{
          let url = TMapApi.getTMapDownUrl()
          result(url)
        }
        break;  
      default:
        result(FlutterMethodNotImplemented)
        break;
        
      }
    })

    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback(registerPlugins)
     if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
       application.registerForRemoteNotifications()

    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func initTmapAPI() {
    TMapApi.setSKTMapAuthenticationWithDelegate(self,apiKey: appKey)
  }

}


func registerPlugins(registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
}
