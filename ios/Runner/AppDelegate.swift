import UIKit
import Flutter
import Firebase
import TMapSDK
@main
@objc class AppDelegate: FlutterAppDelegate, TMapTapiDelegate{
    let appKey: String = "l7xx9363c407318b4b04910193a57d19242a"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "logis.flutter.iostmap", binaryMessenger: controller.binaryMessenger)
        TMapApi.setSKTMapAuthenticationWithDelegate(self, apiKey: appKey)
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            
            switch call.method {
            case "showActivity":
                if let args = call.arguments as? [String: Any],
                let name = args["name"] as? String,
                let latitude = args["lat"] as? Double,
                   let longitude = args["lon"] as? Double {
                    
                    let urlStr = "tmap://route?rGoName=\(name)&rGoX=\(longitude)&rGoY=\(latitude)"
                    
                    guard let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
                    guard let url = URL(string:encodedStr) else {return}
                    
                    guard let appStoreURL = URL(string: "http://itunes.apple.com/app/id431589174") else {return}
                    
                    if(UIApplication.shared.canOpenURL(url)) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

            SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

}


    func registerPlugins(registry: FlutterPluginRegistry) {
        GeneratedPluginRegistrant.register(with: registry)
    }
