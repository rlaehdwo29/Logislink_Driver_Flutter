import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_navi/kakao_flutter_sdk_navi.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/geofence_model.dart';
import 'package:logislink_driver_flutter/common/model/version_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/db/appdatabase.dart';
import 'package:logislink_driver_flutter/page/bridge_page.dart';
import 'package:logislink_driver_flutter/provider/appbar_service.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/provider/notification_service.dart';
import 'package:logislink_driver_flutter/provider/order_service.dart';
import 'package:logislink_driver_flutter/provider/receipt_service.dart';
import 'package:logislink_driver_flutter/provider/user_car_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart' as app_util;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/string_locale_delegate.dart';
import 'common/style_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
AndroidNotificationChannel? channel;
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late AppDataBase database;

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
      AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ));
    }
  }
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await dotenv.load(fileName: 'assets/env/.env');
  AuthRepository.initialize(appKey: dotenv.env['APP_KEY'] ?? '');
  KakaoSdk.init(nativeAppKey: dotenv.env['NATIVE_KEY'] ?? '' ,javaScriptAppKey: dotenv.env['APP_KEY'] ?? '');
  //Firebase Setting
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = AndroidNotificationChannel(
      Const.PUSH_SERVICE_CHANNEL_ID, // id
      '로지스링크 차주용', // title
      importance: Importance.high,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel!);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  database = AppDataBase();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(MyApp()));
  FlutterNativeSplash.remove();
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _openHandleMessage(initialMessage);
    }
    FirebaseMessaging.onMessage.listen(_messageHandle);
    FirebaseMessaging.onMessageOpenedApp.listen(_openHandleMessage);
  }

  void _messageHandle(RemoteMessage message) {
    print("fcm onMessage msg : ${message.notification}");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin?.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: '@mipmap/ic_launcher',
            ),
          ));
    }
  }

  void _openHandleMessage(RemoteMessage message) {
    print("fcm opendApp msg : ${message.messageId}");
    if(message.data.isNotEmpty){
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (message.data["link_page"] == "config") {

        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  Stream<int> get badgeCnt async* {
    final prefs = await SharedPreferences.getInstance();
    while (true) {
      int badgeCnt = 0;
      await Future.delayed(const Duration(seconds: 1), () async {
        await prefs.reload();
        badgeCnt = prefs.getInt('b1_cnt') ?? 0;
      });
      yield badgeCnt;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(App());
    return MultiProvider(
      providers: [
        StreamProvider<int>.value(
            value:badgeCnt,
            initialData:0
        ),
        ChangeNotifierProvider<UserCarInfoService>(
            create: (_) => UserCarInfoService()),
        ChangeNotifierProvider<OrderService>(
            create:(_) => OrderService()),
        ChangeNotifierProvider<ReceiptService>(
            create:(_) => ReceiptService()),
        ChangeNotifierProvider<NotificationService>(
            create:(_) => NotificationService()),
        ChangeNotifierProvider<AppbarService>(
            create: (_) => AppbarService())
      ],
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: ScreenUtilInit(
          designSize: Size(360, 750),
          builder: (_,child) => MaterialApp(
            //navigatorKey: navigatorKey,
            localizationsDelegates: const [
              StringLocaleDelegate(),
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              //Locale('ko', 'KR'),
            ],
            localeResolutionCallback:
                (Locale? locale, Iterable<Locale> supportedLocales) {
              if (locale == null) {
                debugPrint("*language locale is null!!!");
                return supportedLocales.first;
              }

              for (Locale supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode ||
                    supportedLocale.countryCode == locale.countryCode) {
                  debugPrint("*language ok $supportedLocale");
                  return supportedLocale;
                }
              }

              debugPrint("*language to fallback ${supportedLocales.first}");
              return supportedLocales.first;
            },
            title: 'logislink_driver_flutter',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: ThemeData.light()
                  .appBarTheme
                  .copyWith(backgroundColor: main_color),
              primaryColor: main_color,
              backgroundColor: styleWhiteCol,
              textTheme: TextTheme(bodyText1: CustomStyle.baseFont()),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'NanumSquare',
            ),
            home: GetBuilder<App>(
              init: App(),
              builder: (_) {
                app_util.Util.settingInfo();
                //return const BridgePage();
                 return FutureBuilder(
                    future: checkPermission(),
                    builder: (context,snapshot) {
                      return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 1500),
                        child: _splashLodingWidget(snapshot,context),
                      );
                    }
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> checkPermission() async {
  if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    print("권한 설정 완료");
    app_util.Util.toast("권한 설정 완료");
    return true;
  }else{
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.phone,
    ].request();

    print("위치 => ${statuses[Permission.location]}");
    print("저장소 => ${statuses[Permission.storage]}");
    print("저장소2 => ${statuses[Permission.manageExternalStorage]}");
    print("폰 => ${statuses[Permission.phone]}");
    print("권한 설정 미완료");

    //app_util.Util.toast("권한 설정 미완료 => ${statuses[Permission.location]} // ${statuses[Permission.storage]} // ${statuses[Permission.manageExternalStorage]} // ${statuses[Permission.phone]}");

    /*if(statuses[Permission.location] != PermissionStatus.granted){
      //await Permission.location.request();
      return false;
    }else if(statuses[Permission.storage] != PermissionStatus.granted) {
      //await Permission.storage.request();
      return false;
    }else if(statuses[Permission.manageExternalStorage] != PermissionStatus.granted) {
      //await Permission.manageExternalStorage.request();
    }else if(statuses[Permission.phone] != PermissionStatus.granted){
      //await Permission.phone.request();
      return false;
    }*/
    return true; //=> 원래 넘기면 안댐
  }
}


Widget _splashLodingWidget(AsyncSnapshot<Object?> snapshot,BuildContext context) {
  if(snapshot.hasError) {
    return const Text("Error!!");
  }else if(snapshot.hasData){
    if(snapshot.data == true){
      return const BridgePage();
    }else{
      return openOkBox(context, "권한 설정을 모두 허용 후 사용하실 수 있습니다.", Strings.of(context)?.get("confirm")??"Error!!",() {
        Navigator.of(context).pop(false);
        SystemNavigator.pop();
      });
    }
  }else{
    return Container(
      alignment: Alignment.center,
      child: Image.asset("assets/image/ic_bg_service_small.png"),
    );
  }
}
