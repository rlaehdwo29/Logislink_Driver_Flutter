import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geofencing_api/geofencing_api.dart';
import 'package:geolocator/geolocator.dart' as geolocation;

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_main_widget.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/config_url.dart';
import 'package:logislink_driver_flutter/common/model/order_model.dart';
import 'package:logislink_driver_flutter/common/model/stop_point_gps_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/db/appdatabase.dart';
import 'package:logislink_driver_flutter/common/model/geofence_model.dart';
import 'package:logislink_driver_flutter/page/notification_page.dart';
import 'package:logislink_driver_flutter/page/subPage/app_bar_sales_page.dart';
import 'package:logislink_driver_flutter/page/subPage/appbar_monitor_page.dart';
import 'package:logislink_driver_flutter/page/subPage/appbar_mypage.dart';
import 'package:logislink_driver_flutter/page/subPage/app_bar_car_book_page.dart';
import 'package:logislink_driver_flutter/page/subPage/appbar_notice_page.dart';
import 'package:logislink_driver_flutter/page/subPage/appbar_setting_page.dart';
import 'package:logislink_driver_flutter/page/subPage/history_page.dart';
import 'package:logislink_driver_flutter/page/subPage/order_detail_page.dart';
import 'package:logislink_driver_flutter/page/subPage/user_car_list_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class MainPage extends StatefulWidget {
  final String? allocId;
  const MainPage({Key? key, this.allocId}):super(key:key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with CommonMainWidget,WidgetsBindingObserver {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final controller = Get.find<App>();
  final beforeUser = UserModel().obs;
  final _nowUser = UserModel().obs;

  static bool? isRunning;

  static final String DEEP_LINK_ORDER = "order";
  static final String DEEP_LINK_TAX = "tax";
  static final String DEEP_LINK_RECEIPT = "receipt";

  static const SCREEN_HISTORY = "운송실적";
  static const String SCREEN_MONITOR = "실적현황";
  static const String SCREEN_CAR_BOOK = "차계부";

  final GlobalKey webViewKey = GlobalKey();
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;

  static bool isNoticeOpen = false;

  bool geoUpdate = false;
  bool pointUpdate = false;
  final orderList = List.empty(growable: true).obs;
  final pGpsStop = List.empty(growable: true).obs;

  Set<GeofenceRegion> geofenceList = {};

  final _geofenceService = Geofencing.instance.setup(
        interval:60000, // GeoFence 상태 확인 5초마다
        accuracy: 100, // GeoFence 지정 범위 100M
        statusChangeDelay: 10000, // GeoFence 지정 범위 경계 근처에 있을때 상태 변경
        allowsMockLocation: true, // 모의 위치 허용 여부
        printsDebugLog: true, // 개발자 로그 표시 여부
      );

  Future<void> _onGeofenceStatusChanged(
      GeofenceRegion geofenceRegion,
      GeofenceStatus geofenceStatus,
      Location location) async {
    print('region(id: ${geofenceRegion.id}) ${geofenceStatus.name}');
    AppDataBase db = App().getRepository();
    var app = await App().getUserInfo();
    GeofenceModel? data = await db.getGeoFence(app.vehicId, int.parse(geofenceRegion.id));
    if(data != null) {
      if(data.flag == "Y") {
        if(geofenceStatus == GeofenceStatus.enter) {
          if(data.allocState == "E") {
            if(await db.checkEndGeo(app.vehicId, data.orderId) == 1) {
              setOrderState(data, "05");
            }
          } else if(data.allocState == "EP" || data.allocState == "SP") {
            if(data.allocState == "EP") {
              bool? checkGeoEPoint = await db.checkEPointGeo(app.vehicId, data.orderId, data.stopNum);
              if(checkGeoEPoint??false) {
                finishStopPoint(data);
              }
            }
          }else{
            setOrderState(data, "12");
          }
        }else if(geofenceStatus == GeofenceStatus.exit) {
          if(data.allocState == "E") {
            if(await db.checkStartGeo(app.vehicId, data.orderId) == 0) {
              setOrderState(data, "06");
            }
          }else if(data.allocState == "SP" || data.allocState == "EP"){
            bool? checkGeoSPoint = await db.checkSPointGeo(app.vehicId, data.orderId, data.stopNum);
            if(checkGeoSPoint??false) {
              beginStartPoint(data);
            }
          }else{
            setOrderState(data, "04");
          }
        }
      }
    }
  }

  Future<void> finishStopPoint(GeofenceModel data) async {
    AppDataBase db = App().getRepository();
    String? stopSeq = data.stopNum.toString();

    GeofenceModel? removeGeo = await db.getRemoveGeoSEP(data.vehicId, data.orderId, data.allocState, data.stopNum);
    if(removeGeo != null) {
      db.deleteGeoFence(data.vehicId, data.orderId, data.allocState, data.stopNum);
    }

    Logger logger = Logger();
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).finishStopPoint(app.authorization,data.orderId,stopSeq).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("geofence_receiver finishStopPoint() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          FBroadcast.instance().broadcast(Const.INTENT_DETAIL_REFRESH,value: 0);
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("geofence_receiver.dart finishStopPoint() Error Default: ${res?.statusCode} -> ${res?.statusCode} // ${res?.statusMessage} // ${res}");
          break;
        default:
          logger.e("geofence_receiver.dart finishStopPoint() Error Default:");
          break;
      }
    });

  }

  Future<void> beginStartPoint(GeofenceModel data) async {
    AppDataBase db = App().getRepository();
    String? stopSeq = data.stopNum.toString();

    GeofenceModel? removeGeo = await db.getRemoveGeoSEP(data.vehicId, data.orderId, data.allocState, data.stopNum);
    if(removeGeo != null) {
      db.deleteGeoFence(data.vehicId, data.orderId, data.allocState, data.stopNum);
    }

    Logger logger = Logger();
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).beginStartPoint(app.authorization,data.orderId,stopSeq).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("geofence_receiver beginStartPoint() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          FBroadcast.instance().broadcast(Const.INTENT_DETAIL_REFRESH,value: 1);
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("geofence_receiver.dart beginStartPoint() Error Default: ${res?.statusCode} -> ${res?.statusCode} // ${res?.statusMessage} // ${res}");
          break;
        default:
          logger.e("geofence_receiver.dart beginStartPoint() Error Default:");
          break;
      }
    });

  }

  Future<void> setOrderState(GeofenceModel data, String code) async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).setOrderState(app.authorization, data?.orderId, data?.allocId, code).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("geofence_receiver setOrderState() _response -> ${_response.status} // ${_response.resultMap} // $code");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          switch(code) {
            case "04":
            case "06":
              AppDataBase db = App().getRepository();
              db.delete(data);
              FBroadcast.instance().broadcast(Const.INTENT_GEOFENCE);
              break;
          }
          FBroadcast.instance().broadcast(Const.INTENT_DETAIL_REFRESH,value: 3);
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("geofence_receiver.dart setOrderState() Error Default: ${res?.statusCode} -> ${res?.statusCode} // ${res?.statusMessage} // ${res}");
          break;
        default:
          logger.e("geofence_receiver.dart setOrderState() Error Default:");
          break;
      }
    });
  }

  // This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
  }

  // This function is to be called when the location has changed.
  Future<void> _onLocationChanged(Location location) async {
    print('location: ${location.toJson()}');
    double lat = location.latitude;
    double lon = location.longitude;

    await SP.putString(Const.KEY_LAT, lat.toString());
    await SP.putString(Const.KEY_LON, lon.toString());
    List<String>? list = await SP.getStringList(Const.KEY_ALLOC_ID);
    await locationUpdate("",lat,lon);

  }

  Future<void> locationUpdate(String allocId,double lat, double lon) async {
    if(Const.userDebugger) return;
    var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
    if(guest) return;

    Logger logger = Logger();
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).locationUpdate(app.authorization, lat.toString(), lon.toString(),allocId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("locationUpdate() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {

        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("locationUpdate() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("locationUpdate() Error Default => ");
          break;
      }
    });

  }

  // This function is used to handle errors that occur in the service.
  void _onGeofenceError(Object error, StackTrace stackTrace) {
    print('error: $error\n$stackTrace');
  }

  @override
  void initState() {
    super.initState();
    isRunning = true;
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    FBroadcast.instance().register(Const.INTENT_ORDER_REFRESH, (value, callback) async {
      await getOrderMethod(true);
    },context: this);
    FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
    FBroadcast.instance().register(Const.INTENT_GEOFENCE, (value, callback) async {
      await setGeofencingClient();
    });
    pullToRefreshController = (kIsWeb
        ? null : PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController.loadUrl(urlRequest: URLRequest(url: await webViewController.getUrl()));}
      },
    ))!;
    handleDeepLink();
    Future.delayed(Duration.zero, () async {
      _nowUser.value = await controller.getUserInfo();
      await Util.setEventLog(URL_USER_LOGIN, "모바일로그인", loginYn: "Y");
      await setGeofencingClient();
      var first_screen = await SP.getFirstScreen(context);
      switch (first_screen) {
        case SCREEN_HISTORY:
          goToHistory();
          break;
        case SCREEN_MONITOR:
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => AppBarMonitorPage()));
          break;
        case SCREEN_CAR_BOOK:
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => AppBarCarBookPage()));
          break;
      }
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if(Platform.isAndroid) {
        AndroidDeviceInfo info  = await deviceInfo.androidInfo;
        if (info.version.sdkInt >= 29) {
          var locationPermission = await geolocation.Geolocator.checkPermission();
          if(locationPermission != geolocation.LocationPermission.always) {
            await showLocationPermissionDialog();
          }else{
            await checkCarInfo();
          }
        }else{
          await checkCarInfo();
        }
      }else {
        var locationPermission = await geolocation.Geolocator.checkPermission();
        final activityRecognition = FlutterActivityRecognition.instance;
        PermissionRequestResult recognitionResult = await activityRecognition.checkPermission();
        var trackStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
        if(locationPermission != geolocation.LocationPermission.always) {
          await showLocationPermissionDialog();
        }else if(trackStatus != TrackingStatus.authorized){
          var trackingStatus = await AppTrackingTransparency.requestTrackingAuthorization();
          if(trackingStatus != TrackingStatus.authorized) {
            await showTrackingPermissionDialog();
          }
        }else if(recognitionResult != PermissionRequestResult.GRANTED){
          var activityRecognition_per = await activityRecognition.requestPermission();
          if(activityRecognition_per != PermissionRequestResult.GRANTED) {
            await showActivityPermissionDialog();
          }
        }else{
          await checkCarInfo();
        }
      }
        var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
      if (guest) showGuestDialog();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request permissions and initialize the service.
      _requestPermissions();
      _initService();
    });

  }

  void _onReceiveTaskData(Object data) async {
    if (data is int) {
      if(!Geofencing.instance.isRunningService) {
        Geofencing.instance.addGeofenceStatusChangedListener(_onGeofenceStatusChanged);
        Geofencing.instance.addGeofenceErrorCallbackListener(_onGeofenceError);
        await Geofencing.instance.start(regions: geofenceList);
        if (widget.allocId != null) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => OrderDetailPage(allocId: widget.allocId)));
        }
      }
    }
  }

  void handleDeepLink() async {
    
    FirebaseDynamicLinks.instance.getInitialLink().then(
          (PendingDynamicLinkData? dynamicLinkData) {
        // Set up the `onLink` event listener next as it may be received here
        if (dynamicLinkData != null) {
          final Uri deepLink = dynamicLinkData.link;
          String? code = deepLink.pathSegments.last;
          String? allocId = deepLink.queryParameters["allocId"];
          String? orderId = deepLink.queryParameters["orderId"];
          if(allocId == null) return;
          switch(code) {
            case Const.DEEP_LINK_ORDER:
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => OrderDetailPage(allocId: allocId,orderId: orderId)));
              break;
            case Const.DEEP_LINK_TAX:
            case Const.DEEP_LINK_RECEIPT:
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => OrderDetailPage(allocId: allocId,orderId: orderId,code: code)));
              break;
          }
        }
      });

  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  Future<void> setGeofencingClient() async {

    await removeGeofence();

    AppDataBase db = App().getRepository();
    var app = await App().getUserInfo();
    List<GeofenceModel> list = await db.getAllGeoFenceList(app.vehicId);
    if(list != null && list.length != 0) {
      if(geofenceList.isNotEmpty) geofenceList.clear();
      for(var data in list) {
        geofenceList.add(GeofenceRegion.circular(id: data.id.toString(),data: {"orderId": data.orderId,"vehicId":data.vehicId,"allocId":data.allocId,"allocState":data.allocState}, center: LatLng(double.parse(data.lat), double.parse(data.lon)) , radius: double.parse(Const.GEOFENCE_RADIUS_IN_METERS.toString())));
      }
    }
    await addGeofence();
  }

  Future<void> removeGeofence() async {
    Geofencing.instance.removeRegions(geofenceList);
  }

  Future<void> addGeofence() async {
    Geofencing.instance.addRegions(geofenceList);
  }

  Future<void> checkCarInfo() async {
    var app = await App().getUserInfo();
    String? carType = app.carTypeCode;
    String? carTon = app.carTonCode;
    if((carType != null && carType.isNotEmpty) && (carTon != null && carTon.isNotEmpty)) {
      if(!await FlutterForegroundTask.isRunningService) await startGeoService();
    }else{
      showCarSetting();
    }
  }

  Future<void> showLocationPermissionDialog() async {
    return openOkBox(
          context,
          Strings.of(context)?.get("location_permission_failed")??"Not Found",
          Strings.of(context)?.get("confirm")??"Not Found",
              () async {
            Navigator.of(context).pop(false);
            callPermission();
          }
      );
    }

  Future<void> showActivityPermissionDialog() async {
    return openOkBox(
        context,
        Strings.of(context)?.get("activity_permission_failed")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () async {
          Navigator.of(context).pop(false);
          await Permission.activityRecognition.request();
          //await AppSettings.openAppSettings();
        }
    );
  }

  Future<void> showTrackingPermissionDialog() async {
    return openOkBox(
        context,
        Strings.of(context)?.get("tracking_permission_failed")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () async {
          Navigator.of(context).pop(false);
          await Permission.appTrackingTransparency.request();
          //await AppSettings.openAppSettings();
        }
    );
  }

  void onCallback(bool? result) {
    if(result == true) {
      checkCarInfo();
    }
  }

  void showCarSetting() {
    openCommonConfirmBox(
        context,
        "차종과 톤수를 설정하셔야 앱을 사용할 수 있습니다.\n설정 하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () {
          Navigator.of(context).pop(false);
          Navigator.push(context, MaterialPageRoute(builder: (context) => AppBarMyPage(onCallback: onCallback,)));
        }
    );
  }

  Future<bool> checkLocationPermission() async {
    if (await Permission.contacts.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      print("Location 권한 허용");
      return true;
    }else{
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
      ].request();

      if(statuses[Permission.location] != PermissionStatus.granted){
        await Permission.location.request();
      }
      return false;
    }
  }

  Future<void> callPermission() async {
    if(await checkLocationPermission()) {
      await checkCarInfo();
    }else{
      await goToAppSetting();
    }
  }

  Future<void> goToAppSetting() async {
    var locationPermission = await geolocation.Geolocator.checkPermission();
    if(locationPermission != geolocation.LocationPermission.always) {
      await Permission.locationAlways.request();
      //AppSettings.openAppSettings();
    }
    await finishService();
  }

  Future<ServiceRequestResult> startGeoService() async {
    await SP.putBool(Const.KEY_SETTING_WORK, true);
      print("startGeoService");
      await setGeofencingClient();
      if(await FlutterForegroundTask.isRunningService) {
        return FlutterForegroundTask.restartService();
      }else {
        return FlutterForegroundTask.startService(
          serviceId: 1100,
          notificationTitle: '로지스링크에서 현재 위치를 전송중입니다.',
          notificationText: '',
          notificationIcon: null,
          notificationButtons: [],
          callback: startCallback,
        );
      }
  }

  Future<ServiceRequestResult> _stopForeGroundService() async {
    return FlutterForegroundTask.stopService();
  }

  Future<void> finishService() async {
    await stopService();
    exited();
  }

  void exited(){
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      exit(0);
      //SystemNavigator.pop();
    });
  }

  Future<void> stopService() async {
    SP.putBool(Const.KEY_SETTING_WORK, false);
   if(Geofencing.instance.isRunningService) {
     Geofencing.instance.clearAllListeners();
     Geofencing.instance.stop();
   }
    _stopForeGroundService();
  }

  Future<void> goToExit() async {
    var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
    openCommonConfirmBox(
        context,
        "퇴근하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          if(guest) await SP.remove(Const.KEY_USER_INFO);
          await logout();
        }
    );
  }

  Future<void> logout() async {
    await stopService();
    //App().setUserInfo(UserModel());
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      exit(0);
      //SystemNavigator.pop();
    });
  }

  void goToHistory() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HistoryPage()
    ));
  }

  Future<void> getOrderMethod(bool flag) async {
    bool data = flag;
    await getOrder(data);
  }

  Future<void> getOrder(bool flag) async {
    bool data = flag;
    await getOrderList();
    await setAllocList();
    await setGeoList(data);
  }

  Future<void> getOrderList() async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).getOrder(app.authorization, app.vehicId).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOrder() _response -> ${_response.status} // ${_response.resultMap}");
      await Util.setEventLog(URL_USER_LOGIN, "모바일로그인", loginYn: "Y");
      if(_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
          if(orderList.isNotEmpty) orderList.clear();
          try{
            var list = _response.resultMap?["data"] as List;
            List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
            orderList?.addAll(itemsList);
          }catch(e) {
            print(e);
          }
        } else {
          orderList.value = List.empty(growable: true);
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getOrder() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrder() getOrder Default => ");
          break;
      }
    });
  }

  Future<void> setGeoList(bool flag) async {
    bool fData = flag;
    var app = await App().getUserInfo();
    AppDataBase db = App().getRepository();
    String? vehicId = app.vehicId;

    geoUpdate = false;

    for(var data in orderList) {
      if(!(data.allocState == "20")){
        int? sData = await db.checkGeoS(vehicId, data.orderId);
        if(sData == 0) {
          await db.setGeofence(GeofenceModel(vehicId: vehicId, orderId: data.orderId, allocId: data.allocId, allocState: "S", lat: data.sLat.toString(), lon: data.sLon.toString(),endDate: data.eDate, flag: data.autoCarTimeYn,stopNum: 1));
          geoUpdate = true;
        }

        int? eData = await db.checkGeoE(vehicId, data.orderId);
        if(eData == 0) {
          await db.setGeofence(GeofenceModel(vehicId: vehicId, orderId: data.orderId, allocId: data.allocId, allocState: "E", lat: data.eLat.toString(), lon: data.eLon.toString(),endDate: data.eDate, flag: data.autoCarTimeYn,stopNum: 1));
          geoUpdate = true;
        }
      }
    }
    getStopPointGps(fData);
  }

  Future<void> setStopPointList(bool flag) async {
    bool pData = flag;

    AppDataBase db = App().getRepository();
    var app = await App().getUserInfo();
    String? vehicId = app.vehicId;

    if(pGpsStop.length != 0) {
      for(var data in pGpsStop) {
        if(data != null) {
          if(data.finishYn == "N") {
            int? epData = await db.checkGeoEP(vehicId, data.orderId, data.stopSeq);
            if(epData == 0) {
              db?.setGeofence(GeofenceModel(vehicId: vehicId, orderId: data.orderId, allocId: data.allocId, allocState: "EP", lat: data.pointLat.toString(), lon: data.pointLon.toString(),endDate: data.endDate, flag: data.autoCarTimeYn,stopNum: data.stopSeq));
              pointUpdate = true;
            }
          }

          if(data.beginYn == "N") {
            int? spData = await db.checkGeoSP(vehicId, data.orderId, data.stopSeq);
            if(spData == 0) {
              db.setGeofence(GeofenceModel(vehicId: vehicId, orderId: data.orderId, allocId: data.allocId, allocState: "SP", lat: data.pointLat.toString(), lon: data.pointLon.toString(),endDate: data.endDate, flag: data.autoCarTimeYn,stopNum: data.stopSeq));
              pointUpdate = true;
            }
          }
        }
      }
    }else{
      pointUpdate = false;
    }

    if(geoUpdate || pointUpdate) {
      geoUpdate = false;
      pointUpdate = false;
      if(pData) {
        FBroadcast.instance().broadcast(Const.INTENT_GEOFENCE);
      }
    }

  }

  Future<void> getStopPointGps(bool flag) async {
    bool data = flag;
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).getStopPointGps(app.authorization, app.vehicId, app.driverId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getStopPointGps() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          var list = _response.resultMap?["data"] as List;
          List<StopPointGpsModel> itemsList = list.map((i) =>
              StopPointGpsModel.fromJSON(i)).toList();
          if (pGpsStop.isNotEmpty == true) pGpsStop.value = List.empty(growable: true);
          pGpsStop.value?.addAll(itemsList);
          setStopPointList(data);
        } else {
          openOkBox(context, _response.resultMap?["error_message"],
              Strings.of(context)?.get("close") ?? "Not Found", () {
                Navigator.of(context).pop(false);
              });
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getStopPointGps() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getStopPointGps() Error Default => ");
          break;
      }
    });
  }

  Future<void> setAllocList() async {
    List<String> allocList = List.empty(growable: true);
    for(var data in orderList) {
      if(!(data.allocState == "20")) allocList.add(data.allocId);
    }
    await SP.putStringList(Const.KEY_ALLOC_ID, allocList);
  }

  void showGuestDialog(){
    openOkBox(context, Strings.of(context)?.get("Guest_Intro_Mode")??"Error", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
  }

  void goToOrderDetail(OrderModel item){
    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailPage(item: item)));
  }

  Drawer getAppBarMenu() {
    return Drawer(
        backgroundColor: styleWhiteCol,
        width: MediaQuery.of(context).size.width * 0.5,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: main_color,
                ),
                child: InkWell(
                    onTap: () async {
                      beforeUser.value = await controller.getUserInfo();
                      var results = await Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => UserCarListPage())
                      );

                      if(results != null && results.containsKey("code")){
                        if(results["code"] == 200) {
                          String? vehic = beforeUser.value.vehicId;
                          AppDataBase db = App().getRepository();
                          List<GeofenceModel> list = await db.getAllGeoFenceList(vehic);
                          db.deleteAll(list);
                          getUserInfo();
                          await getOrderMethod(true);
                          //Navigator.pop(context);
                          _scaffoldKey.currentState!.closeDrawer();
                        }
                      }
                    },
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(()=>
                              Text(
                                "${_nowUser.value.driverName} 차주님",
                                style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                              )),
                          CustomStyle.sizedBoxHeight(10.0),
                          Obx(()=>Text(
                            "${_nowUser.value.carNum}",
                            style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                          )
                          )
                        ]
                    )
                )
            ),

            ListTile(
              title: Text(
                "내정보",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => AppBarMyPage()));
              },
            ),
            ListTile(
              title: Text(
                "실적현황",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => AppBarMonitorPage()));
              },
            ),
            ListTile(
              title: Text(
                "차계부",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => AppBarCarBookPage()));
              },
            ),
            ListTile(
              title: Text(
                "매출관리",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => AppBarSalesPage()));
              },
            ),
            ListTile(
              title: Text(
                "공지사항",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => AppBarNoticePage()));
              },
            ),
            ListTile(
              title: Text(
                "설정",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => AppBarSettingPage()));
              },
            ),ListTile(
              title: Text(
                "도움말",
                style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
              ),
              onTap: () async {
                var url = Uri.parse(URL_MANUAL);
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                }
              },
            ),ListTile(
              title: Text(
                "퇴근하기",
                style: CustomStyle.CustomFont(styleFontSize14, order_state_09),
              ),
              onTap: () async {
                await goToExit();
              },
            )
          ],
        )
    );
  }

  Future<void> getUserInfo() async {
    Logger logger = Logger();
    UserModel? nowUser = await controller.getUserInfo();
    await DioService.dioClient(header: true).getUserInfo(nowUser?.authorization, nowUser?.vehicId).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("getUserInfo() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
          try {
            UserModel newUser = UserModel.fromJSON(it.response.data["data"]);
            newUser.authorization = nowUser?.authorization;
            controller.setUserInfo(newUser);
            _nowUser.value = newUser;
          }catch(e) {
            print(e);
          }
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getUserInfo() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getUserInfo() Exepction => ");
          break;
      }
    });

  }

  Widget getListCardView(OrderModel item) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0.h),horizontal: CustomStyle.getWidth(10.0.w)),
        child: InkWell(
            onTap: () {
              goToOrderDetail(item);
            },
            child: Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0)),
                color: styleWhiteCol,
                child: Column(children: [
                  Container(
                      padding:  EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0.h),horizontal: CustomStyle.getWidth(10.0.w)),
                      color: order_item_background,
                      child: Column(children: [
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Flexible(
                                flex: 3,
                                child: Row(children: [
                                  Container(
                                      decoration: CustomStyle
                                          .baseBoxDecoWhite(),
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                          CustomStyle.getHeight(
                                              5.0),
                                          horizontal:
                                          CustomStyle.getWidth(
                                              10.0)),
                                      child: Text(
                                        "${item.allocStateName}",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            Util.getOrderStateColor(
                                                item.allocStateName)),
                                      )),
                                  Container(
                                      padding: EdgeInsets.only(
                                          left: CustomStyle.getWidth(
                                              10.0),
                                          right: CustomStyle.getWidth(
                                              5.0)),
                                      child: Text(
                                        "${item.sellCustName}",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            main_color),
                                      )),
                                  Text(
                                    "${item.sellDeptName}",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10, main_color),
                                  )
                                ])),
                            Util.ynToBoolean(item.payType)
                                ? Flexible(
                                flex: 1,
                                child: Container(
                                  alignment:
                                  Alignment.centerRight,
                                  child: Text(
                                    "빠른지급",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12,
                                        order_state_09),
                                  ),
                                ))
                                : const SizedBox()
                          ],
                        ),
                        CustomStyle.sizedBoxHeight(5.0),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: CustomStyle.getHeight(10.0),
                              horizontal: CustomStyle.getWidth(20.0)),
                          decoration:
                          CustomStyle.customBoxDeco(cancel_btn),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${Util.makeDistance(item.distance)} ${Util.makeTime(item.time)}",
                                style: CustomStyle.CustomFont(
                                    styleFontSize10, styleWhiteCol),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${item.carTypeName}  /  ${item.carTonName}",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10,
                                        styleWhiteCol),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        CustomStyle.sizedBoxHeight(10.0),
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(children: [
                                Text(
                                  Util.makeString(item.sSido)??"Error",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, main_color,
                                      font_weight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  Util.makeString(item.sGungu)??"Error",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, main_color,
                                      font_weight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                CustomStyle.sizedBoxHeight(5.0),
                                Text(
                                  Util.makeString(item.sDong)??"Error",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize12, main_color),
                                  textAlign: TextAlign.center,
                                ),
                              ]),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Icon(Icons.arrow_forward),
                            ),
                            Expanded(
                                flex: 4,
                                child: Column(children: [
                                  Text(
                                    Util.makeString(item.eSido)??"Error",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize16, main_color,
                                        font_weight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    Util.makeString(item.eGungu)??"Error",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize16, main_color,
                                        font_weight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  CustomStyle.sizedBoxHeight(5.0),
                                  Text(
                                    Util.makeString(item.eDong)??"Error",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12, main_color),
                                    textAlign: TextAlign.center,
                                  )
                                ]))
                          ],
                        ),
                        CustomStyle.sizedBoxHeight(5.0),
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                      CustomStyle.getHeight(5.0),
                                      horizontal:
                                      CustomStyle.getHeight(
                                          10.0)),
                                  decoration:
                                  CustomStyle.baseBoxDecoWhite(),
                                  child: Text(
                                    "상차 ${Util.splitSDate(item.sDate)}",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10,
                                        text_color_01),
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                  child: Icon(
                                    Icons.linear_scale_sharp,
                                    color: text_color_01,
                                  )),
                            ),
                            Expanded(
                                flex: 4,
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                        CustomStyle.getHeight(
                                            5.0),
                                        horizontal:
                                        CustomStyle.getHeight(
                                            10.0)),
                                    decoration: CustomStyle
                                        .baseBoxDecoWhite(),
                                    child: Text(
                                      "하차 ${Util.splitEDate(item.eDate)}",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(
                                          styleFontSize10,
                                          text_color_01),
                                    )))
                          ],
                        )
                      ])),
                  Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Text(
                            item.returnYn == "Y" ? "왕복" : "편도",
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_02),
                          ),
                          CustomStyle.sizedBoxWidth(10.0),
                          Text(
                            item.mixYn == "Y" ? "혼적" : "독차",
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_02),
                          ),
                        ],
                      ))
                ]
                )
            )
        )
    );
  }

  Future<void> _requestPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermissionStatus = await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      //await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
      // onNotificationPressed function to be called.
      //
      // When the notification is pressed while permission is denied,
      // the onNotificationPressed function is not called and the app opens.
      //
      // If you do not use the onNotificationPressed or launchApp function,
      // you do not need to write this code.
      /*if (!await FlutterForegroundTask.canDrawOverlays) {
        // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
        await FlutterForegroundTask.openSystemAlertWindowSettings();
      }*/

      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      /*if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }*/
    }
  }

  Future<void> _initService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: Const.LOCATION_SERVICE_CHANNEL_ID,
        channelName: '로지스링크 차주용',
        channelDescription: 'This notification appears when the geofence service is running in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(60000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Util.notificationDialog(context,"기본",webViewKey);
    return WithForegroundTask(
            child: SafeArea(
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: order_item_background,
                  appBar: AppBar(
                    backgroundColor: main_color,
                    title: Center(
                      child: Image.asset(
                        "assets/image/ic_driver_header.png",
                        width: CustomStyle.getWidth(150.0),
                        height: CustomStyle.getHeight(60.0),
                      ),
                    ),
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                          onPressed: () async {
                            await goToExit();
                          },
                          icon: Image.asset("assets/image/ic_exit_hangul.png",width: CustomStyle.getWidth(32.0.w),height: CustomStyle.getHeight(32.0.h),)),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => NotificationPage()
                            ));
                          },
                          icon: Icon(Icons.notifications, size: 24.0.h,color: Colors.white,)),
                    ],
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: Image.asset("assets/image/menu.png",
                            width: CustomStyle.getWidth(20.0),
                            height: CustomStyle.getHeight(20.0)),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                      ),
                    ),
                  ),
                  drawer: getAppBarMenu(),
                  body: Obx((){
                        return orderList.isNotEmpty ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: orderList.length,
                          itemBuilder: (context, index) {
                            var item = orderList[index];
                            return getListCardView(item);
                          },
                        ) : Container(
                            alignment: Alignment.center,
                            child:Center(
                                child:Text(
                                  Strings.of(context)?.get("empty_list")??"Not Found",
                                  style: CustomStyle.baseFont(),
                                )
                            )
                        );
                      }),
                  bottomNavigationBar:  SizedBox(
                      height: CustomStyle.getHeight(60.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 1,
                              child: InkWell(
                                  onTap: (){
                                    goToHistory();
                                  },
                                  child: Container(
                                      height: CustomStyle.getHeight(60.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: main_color
                                      ),
                                      child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.library_add_check,size: 20,color: styleWhiteCol),
                                            CustomStyle.sizedBoxWidth(5.0),
                                            Text(
                                              textAlign: TextAlign.center,
                                              Strings.of(context)?.get("history_title")??"Not Found",
                                              style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                                            ),
                                          ])
                                  )
                              )
                          ),
                        ],
                      )
                  ),
                ))
          );
  }
}

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  int _count = 0;

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart');
  }

  // Called by eventAction in [ForegroundTaskOptions].
  // - nothing() : Not use onRepeatEvent callback.
  // - once() : Call onRepeatEvent only once.
  // - repeat(interval) : Call onRepeatEvent at milliseconds interval.
  @override
  void onRepeatEvent(DateTime timestamp) {
    print('onRepeatEvent');

    // Send data to main isolate.
      FlutterForegroundTask.updateService();
      FlutterForegroundTask.sendDataToMain(_count);
    _count++;
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('onDestroy');
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  //
  // AOS: "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted
  // for this function to be called.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  //
  // AOS: only work Android 14+
  // iOS: only work iOS 10+
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}