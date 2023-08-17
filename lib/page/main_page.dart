import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/provider/geofence_receiver.dart';
import 'package:logislink_driver_flutter/provider/order_service.dart';
import 'package:logislink_driver_flutter/service/gps_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class MainPage extends StatefulWidget {
  final String? allocId;
    const MainPage({Key? key, this.allocId}):super(key:key);
    @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with CommonMainWidget {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final controller = Get.find<App>();

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

  UserModel? beforeUser = null;

  static bool isNoticeOpen = false;

  bool geoUpdate = false;
  bool pointUpdate = false;
  final orderList = List.empty(growable: true).obs;
  final pGpsStop = List.empty(growable: true).obs;

  @override
  void initState() {
    super.initState();
    isRunning = true;
    FBroadcast.instance().register(Const.INTENT_ORDER_REFRESH, (value, callback) {
      getOrderMethod(true);
    });
    FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue,),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController.loadUrl(urlRequest: URLRequest(url: await webViewController.getUrl()));}
      },
    ))!;

    Future.delayed(Duration.zero, () {
      switch (SP.getFirstScreen(context)) {
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

      FBroadcast.instance().register(Const.INTENT_GEOFENCE, (value, callback) {
        setGeofencingClient();
      });

      showPermissionDialog();

      if (SP.getBoolean(Const.KEY_GUEST_MODE)) showGuestDialog();

    });
  }

  void setGeofencingClient() {
    removeGeofence();
  }

  void removeGeofence() {

  }

  @override
  void dispose() {
    FBroadcast.instance().unregister(this);
    super.dispose();
  }

  void checkCarInfo() {
    String? carType = App().getUserInfo()?.carTypeCode;
    String? carTon = App().getUserInfo()?.carTonCode;

    if((carType != null && carType.isNotEmpty) && (carTon != null && carTon.isNotEmpty)) {
      startService();
    }else{
      showCarSetting();
    }
  }

  void showPermissionDialog() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();

    if (statuses[Permission.location] != PermissionStatus.granted) {
      openCommonConfirmBox(
          context,
          Strings.of(context)?.get("location_permission_failed")??"Not Found",
          Strings.of(context)?.get("cancel")??"Not Found",
          Strings.of(context)?.get("confirm")??"Not Found",
              () {Navigator.of(context).pop(false);},
              () async {
            Navigator.of(context).pop(false);
            callPermission();
          }
      );
    }else{
      checkCarInfo();
    }
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

      print("위치 => ${statuses[Permission.location]}");
      print("Location 권한 비허용");

      if(statuses[Permission.location] != PermissionStatus.granted){
        await Permission.location.request();
      }
      return false;
    }
  }

  Future<void> callPermission() async {
    if(await checkLocationPermission()) {
      checkCarInfo();
    }else{
      goToAppSetting();
    }
  }

  void goToAppSetting() {
    if(Permission.location == PermissionStatus.denied) {
      AppSettings.openAppSettings();
    }
    finishService();
  }

  Future<void> startService() async {
    SP.putBool(Const.KEY_SETTING_WORK, true);
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    if(!isRunning) {
      GpsService.initializeService();
    }

    if(widget.allocId != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailPage(allocId: widget.allocId)));
    }

  }

  void finishService() {
    stopService();
    exited();
  }

  void exited(){
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      exit(0);
    });
  }

  Future<void> stopService() async {
    SP.putBool(Const.KEY_SETTING_WORK, false);
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    if(isRunning) {
      service.invoke("stopService");
    }
  }

  void goToExit() {
    openCommonConfirmBox(
        context,
        "퇴근하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () {
          Navigator.of(context).pop(false);
          if(SP.getBoolean(Const.KEY_GUEST_MODE)) SP.remove(Const.KEY_USER_INFO);
          logout();
        }
    );
  }

  void logout() {
    stopService();
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      exit(0);
  });
  }

  void goToHistory() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HistoryPage()
    ));
  }

  void getOrderMethod(bool flag) {
    bool data = flag;
    getOrder(data);
  }

  Future<void> getOrder(bool flag) async {
    bool data = flag;
    var logger = Logger();
    UserModel? user = controller.getUserInfo();
    final orderService = Provider.of<OrderService>(context,listen: false);
    orderList.value = await orderService.getOrder(context,user?.authorization, user?.vehicId);
    setAllocList();
    setGeoList(data);
  }

  Future<void> setGeoList(bool flag) async {
    bool fData = flag;
    AppDataBase db = App().getRepository();
    String? vehicId = App().getUserInfo()?.vehicId;

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
    String? vehicId = App().getUserInfo()?.vehicId;

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
    await DioService.dioClient(header: true).getStopPointGps(App().getUserInfo()?.authorization, App().getUserInfo()?.vehicId, App().getUserInfo()?.driverId).then((it) {
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

  void setAllocList() {
    List<String> allocList = List.empty(growable: true);
      for(var data in orderList) {
        if(!(data.allocState == "20")) allocList.add(data.allocId);
      }
      SP.putStringList(Const.KEY_ALLOC_ID, allocList);
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: main_color,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${controller.getUserInfo()?.driverName} 차주님",
                        style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol),
                      ),
                      CustomStyle.sizedBoxHeight(10.0),
                      Text(
                        "${controller.getUserInfo()?.carNum}",
                        style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                      )
                    ]
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
              onTap: (){
                goToExit();
              },
            )
          ],
        )
    );
  }

  Widget getListCardView(OrderModel item) {
    return Container(
        padding: const EdgeInsets.all(10.0),
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
                      padding: const EdgeInsets.all(10.0),
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
                            Expanded(
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
                      padding: EdgeInsets.all(10.0),
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

  @override
  Widget build(BuildContext context) {
    return mainWidget(context,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: order_item_background,
          appBar: AppBar(
              title: Center(
                child: Image.asset(
                  "assets/image/ic_driver_header.png",
                  width: CustomStyle.getWidth(170.0),
                ),
              ),
              centerTitle: true,
            automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    onPressed: () {
                      goToExit();
                    },
                    icon: Image.asset("assets/image/ic_exit_hangul.png",width: CustomStyle.getWidth(32.0),height: CustomStyle.getHeight(32.0),)),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NotificationPage()
                      ));
                    },
                    icon: const Icon(Icons.notifications, size: 24.0,color: Colors.white,)),
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
          body: Obx(() {
              return SafeArea(
                  child: orderList.isNotEmpty ?ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  var item = orderList[index];
                  return getListCardView(item);
                },
              ): Container(
                      alignment: Alignment.center,
                    child:Center(
                      child:Text(
                        Strings.of(context)?.get("empty_list")??"Not Found",
                          style: CustomStyle.baseFont(),
                      )
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
        )
    );
  }
}