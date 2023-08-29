import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geofence_service/models/geofence.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/model/geofence_model.dart';
import 'package:logislink_driver_flutter/db/appdatabase.dart';
import 'package:logislink_driver_flutter/provider/geofence_receiver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/const.dart';

class GpsService {

  static List<Geofence> geofenceList = List.empty(growable: true);
  
  // Background Service
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Const.LOCATION_SERVICE_CHANNEL_ID, // id
      '로지스링크 차주용', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
      enableVibration: false,
      playSound: false
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: IOSInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: Const.LOCATION_SERVICE_CHANNEL_ID,
        initialNotificationTitle: '로지스링크 차주용',
        initialNotificationContent: '로지스링크에서 현재 위치를 전송중입니다.',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );

    FBroadcast.instance().broadcast(Const.INTENT_GEOFENCE);
    await setGeofencingClient();
    service.startService();
  }

  static Future<void> setGeofencingClient() async {
    AppDataBase db = App().getRepository();
    List<GeofenceModel> list = await db.getAllGeoFenceList(App().getUserInfo()?.vehicId);
    print("설마 얘가 없나? => ${list.length}");
    if(list != null && list.length != 0) {
      if(geofenceList.isNotEmpty) geofenceList.clear();
      for(var data in list) {
        geofenceList?.add(Geofence(id: data.id.toString(), latitude: double.parse(data.lat), longitude: double.parse(data.lon), radius: [GeofenceRadius(id: 'radius_150', length: double.parse(Const.GEOFENCE_RADIUS_IN_METERS.toString()))]));
      }
    }
    GeoFenceReceiver.initGeoFence(geofenceList);
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final log = preferences.getStringList('log') ?? <String>[];
    log.add(DateTime.now().toIso8601String());
    await preferences.setStringList('log', log);

    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // For flutter prior to version 3.0.0
    // We have to register the plugin manually

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("hello", "world");

    /// OPTIONAL when use custom notification
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
      GeoFenceReceiver.stopGeofence();
    });

    // bring to foreground
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          /// OPTIONAL for use custom notification
          /// the notification id must be equals with AndroidConfiguration when you call configure() method.
          flutterLocalNotificationsPlugin.show(
            888,
            'COOL SERVICE',
            'Awesome ${DateTime.now()}',
             NotificationDetails(
              android: AndroidNotificationDetails(
                Const.LOCATION_SERVICE_CHANNEL_ID, // id
                '로지스링크 차주용', //
                icon: 'ic_bg_service_small',
                ongoing: true,
                enableVibration: false,
                playSound: false,

              ),
            ),
          );

          // if you don't using custom notification, uncomment this
          service.setForegroundNotificationInfo(
            title: "로지스링크 차주용",
            content: "로지스링크에서 현재 위치를 전송중입니다.",
          );
        }
      }

      /// you can see this log in logcat
      print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
    });

  // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );

  }

}