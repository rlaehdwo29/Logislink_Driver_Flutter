import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_navi/kakao_flutter_sdk_navi.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/geofence_model.dart';
import 'package:logislink_driver_flutter/common/model/order_model.dart';
import 'package:logislink_driver_flutter/common/model/stop_point_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/db/appdatabase.dart';
import 'package:logislink_driver_flutter/page/subPage/appbar_mypage.dart';
import 'package:logislink_driver_flutter/page/subPage/receipt_page.dart';
import 'package:logislink_driver_flutter/page/subPage/tax_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/provider/order_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart' as app_util;
import 'package:logislink_driver_flutter/widget/show_bank_check_widget.dart';
import 'package:phone_call/phone_call.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/model/code_model.dart';

class OrderDetailPage extends StatefulWidget {
  OrderModel? item;
  String? allocId,orderId,code;
  OrderDetailPage({Key? key, this.item, this.allocId, this.orderId,this.code}):super(key: key);

  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> with WidgetsBindingObserver {

  final controller = Get.find<App>();
  final isExpanded = [].obs;
  final finished = false.obs;
  final _isChecked = false.obs;

  final tvReceipt = false.obs;
  final tvTax = false.obs;
  final tvPay = false.obs;

  var code;

  ProgressDialog? pr;

  bool isInit = false;
  String platformVersion = "Unknown";
  String initStatus = "Unknown";

  late KakaoMapController? mapController;
  final platform = const MethodChannel("logis.flutter.tmap");
  final iosPlatform = const MethodChannel("logis.flutter.iostmap");
  Set<Marker> markers = {};
  final app = UserModel().obs;
  final orderItem = OrderModel().obs;
  final stopPointList = List.empty(growable: true).obs;

  final mAllocId = "".obs;
  final mOrderId = "".obs;

  late AppLifecycleState _notification;

  @override
  void initState() {
    FBroadcast.instance().register(Const.INTENT_DETAIL_REFRESH, (value, callback) async {
      await getOrderDetail(orderItem.value?.allocId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      app.value = await controller.getUserInfo();

      if(widget.item != null) {
        orderItem.value = widget.item!;
        await initView();
      }else{
        if(widget.allocId != null) {
          mAllocId.value = widget.allocId!;
          mOrderId.value = widget.orderId!;
          code = widget.code;
          await getOrderList2(mAllocId.value,mOrderId.value);
        }else{
          Navigator.of(context).pop(false);
        }
      }

    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _callback(String? bankCd, String? acctNm, String? acctNo) async {
    UserModel user = await controller.getUserInfo();
    user.bankCode = bankCd;
    user.bankCnnm = acctNm;
    user.bankAccount = acctNo;
    controller.setUserInfo(user);
    var app_user = await controller.getUserInfo();
    setState(() {});
  }

  void onCallback(bool? refresh) async {
    //setState(() async {
      if (refresh != null) {
        if (refresh) {
          app.value = await controller.getUserInfo();
        }
      }
   // });
  }

  void naviCheck(String? type) {
    if(type == "S") {
      if(orderItem.value?.sDong?.isNotEmpty == true) {
        initNavi(orderItem.value?.sComName, orderItem.value?.sLat, orderItem.value?.sLon);
      }else{
        app_util.Util.toast("상차지가 불분명하여 길안내를 할 수 없습니다.");
      }
    }else if(type == "E"){
      if(orderItem.value?.eDong?.isNotEmpty == true) {
        initNavi(orderItem.value?.eComName, orderItem.value?.eLat, orderItem.value?.eLon);
      }else{
        app_util.Util.toast("하차지가 불분명하여 길안내를 할 수 없습니다.");
      }
    }
  }

  Future<void> _showActivity(String? name, double? lat, double? lon) async {
    try {
      var values = <String, dynamic>{
        'name': name,
        'lat': lat,
        'lon': lon
      };
      if(io.Platform.isAndroid){
        await platform.invokeMethod('showActivity',values);
      }else{
        await iosPlatform.invokeMethod('showActivity',values);
      }
    } on PlatformException catch (e) {
      log("Error : $e");
    }
  }

  Future<void> initNavi(String? name, double? lat, double? lon) async {
    var navi = await SP.getNavi();
    if(navi == "카카오내비") {
      bool result = await NaviApi.instance.isKakaoNaviInstalled();
      if(result){
        await NaviApi.instance.navigate(
            destination:
            Location(name: "$name", x: "$lon", y: "$lat"),
            option: NaviOption(coordType: CoordType.wgs84)
        );
      }else{
        launchBrowserTab(Uri.parse(NaviApi.webNaviInstall));
      }
    }else {
      _showActivity(name,lat,lon);
    }
  }

  Widget setStopPointPanel(AsyncSnapshot snapshot) {
    if(stopPointList.isNotEmpty) stopPointList.clear();
    stopPointList.value.addAll(snapshot.data);
    isExpanded.value = List.empty(growable: true);
    isExpanded.value = List.filled(stopPointList.length, false);

    return SingleChildScrollView(
        child: Flex(
          direction: Axis.vertical,
          children: List.generate(stopPointList.length, (index) {
            var iData = stopPointList[index];
            return ExpansionPanelList.radio(
              animationDuration: const Duration(milliseconds: 500),
              dividerColor: const Color(0xfffafafa),
              expandedHeaderPadding: EdgeInsets.only(bottom: 0.0.h),
              elevation: 0,
              children: [
                ExpansionPanelRadio(
                  value: index,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: CustomStyle.getWidth(10.0),
                            vertical: CustomStyle.getHeight(10.0)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                                flex:2,
                                child: Container(
                                  decoration: CustomStyle.customBoxDeco(styleWhiteCol,
                                      border_color: !app_util.Util.ynToBoolean(iData.finishYn)? sub_color:text_color_02),
                                  padding: EdgeInsets.symmetric(
                                      vertical: CustomStyle.getHeight(5.0),
                                      horizontal: CustomStyle.getWidth(10.0)),
                                  child: Text(
                                    "경유지 ${iData.stopNo}",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10, !app_util.Util.ynToBoolean(iData.finishYn)? sub_color:text_color_02),
                                  ),
                                )
                            ),
                            Flexible(
                              flex: 6,
                              child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                                  child: RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                      text: TextSpan(
                                        text: "${iData.eComName}",
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                      )
                                  )
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: Text(
                                  iData.stopSe == "S"?"상차":"하차",
                                  style: CustomStyle.CustomFont(styleFontSize12, order_state_04),
                                )
                            )
                          ],
                        ));
                  },
                  body: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: line,
                                  width: CustomStyle.getWidth(1.0)
                              )
                          )
                      ),
                      padding: EdgeInsets.only(top: CustomStyle.getHeight(5.0),right: CustomStyle.getWidth(10.0),left: CustomStyle.getWidth(10.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "${iData.eStaff}",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ),
                              iData.eStaff.isEmpty != true && iData.eTel.isEmpty != true? Text(
                                "  /  ",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              ): const SizedBox(),
                              InkWell(
                                  onTap: () async {
                                    if(io.Platform.isAndroid) {
                                      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                                      AndroidDeviceInfo info = await deviceInfo.androidInfo;
                                      if (info.version.sdkInt >= 23) {
                                        await PhoneCall.calling("${iData.eTel}");
                                      }else{
                                        await launch("tel://${iData.eTel}");
                                      }
                                    }else{
                                      await launch("tel://${iData.eTel}");
                                    }

                                  },
                                  child: Text(
                                    "${iData.eTel}",
                                    style: CustomStyle.CustomFont(styleFontSize12, sub_color),
                                  )
                              )
                            ],
                          ),
                          Container(
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(5.0)),
                              child: Text(
                                "${iData.eAddr}",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              )
                          ),
                          iData.eAddrDetail.isEmpty != true ? Container(
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(5.0)),
                              child: Text(
                                "${iData.eAddrDetail}",
                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              )
                          ):const SizedBox(),
                          Container(
                              margin: EdgeInsets.only(top: CustomStyle.getHeight(10.0)),
                              child: Row(
                                children: [
                                  !(app_util.Util.ynToBoolean(iData.finishYn)) ? Expanded(
                                    flex: 1,
                                    child: InkWell(
                                        onTap: (){
                                          initNavi(iData.eComName, iData.eLat, iData.eLon);
                                        },
                                        child: Container(
                                            decoration: CustomStyle.customBoxDeco(sub_color,radius: styleRadius5),
                                            padding: const EdgeInsets.all(5.0),
                                            margin: EdgeInsets.only(right: CustomStyle.getWidth(5.0)),
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              Strings.of(context)?.get("order_detail_stop_nevi")??"Not Found",
                                              style: CustomStyle.CustomFont(styleFontSize12, styleWhiteCol),
                                            )
                                        )
                                    ),
                                  ) : const SizedBox(),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                        onTap: (){
                                          if(!app_util.Util.ynToBoolean(iData.finishYn)) onFinishStopPoint(iData);
                                        },
                                        child: Container(
                                            decoration: CustomStyle.customBoxDeco(!app_util.Util.ynToBoolean(iData.finishYn) ?sub_color:text_color_02,radius: styleRadius5),
                                            padding: const EdgeInsets.all(5.0),
                                            margin: EdgeInsets.only(right: CustomStyle.getWidth(5.0)),
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              "${Strings.of(context)?.get("order_end")??"Not Found"}${iData.finishDate != null?" (${app_util.Util.getDateStrToStr(iData.finishDate, "MM.dd HH:mm")})":""}",
                                              style: CustomStyle.CustomFont(styleFontSize12, styleWhiteCol),
                                            )
                                        )
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                        onTap: (){
                                          if(!app_util.Util.ynToBoolean(iData.beginYn)) onBeginStartPoint(iData);
                                        },
                                        child: Container(
                                            decoration: CustomStyle.customBoxDeco(!app_util.Util.ynToBoolean(iData.beginYn) ?sub_color:text_color_02,radius: styleRadius5),
                                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              "${Strings.of(context)?.get("order_start")??"Not Found"}${iData.beginDate != null?" (${app_util.Util.getDateStrToStr(iData.beginDate, "MM.dd HH:mm")})":""}",
                                              style: CustomStyle.CustomFont(styleFontSize12, styleWhiteCol),
                                            )
                                        )
                                    ),
                                  ),
                                ],
                              )
                          ),
                          CustomStyle.sizedBoxHeight(10.0)
                        ],
                      )
                  ),
                  canTapOnHeader: true,
                )
              ],
              expansionCallback: (int _index, bool status) {
                isExpanded[index] = !isExpanded[index];
                for (int i = 0; i < isExpanded.length; i++)
                  if (i != index) isExpanded[i] = false;
              },
            );
          }),
        )
    );
  }

  void onFinishStopPoint(StopPointModel iData) {
    if(orderItem.value?.allocState == "04") {
      openCommonConfirmBox(
          context,
          "경유지에 도착하셨습니까?",
          Strings.of(context)?.get("cancel")??"Not Found",
          Strings.of(context)?.get("confirm")??"Not Found",
              () => Navigator.of(context).pop(false),
              () async {
            Navigator.of(context).pop(false);
            await finishStopPoint(iData);
          });
    }else{
      app_util.Util.toast("상차 진행중 및 도착 처리시 경유지 도착처리가 불가능합니다.");
    }
  }

  void onBeginStartPoint(StopPointModel iData) {
    if(orderItem.value?.allocState == "04") {
      openCommonConfirmBox(
          context,
          "경유지에서 출발 하겠습니까?",
          Strings.of(context)?.get("cancel")??"Not Found",
          Strings.of(context)?.get("confirm")??"Not Found",
              () => Navigator.of(context).pop(false),
              () async {
            Navigator.of(context).pop(false);
            await beginStartPoint(iData);
          });
    }else{
      app_util.Util.toast("미 출발 및 도착 처리시 경유지 출발처리가 불가능합니다.");
    }
  }

  Future<void> finishStopPoint(StopPointModel data) async {
    set_EP_SP("EP");
    Logger logger = Logger();
    var app = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).finishStopPoint(app.authorization, data.orderId, data.stopSeq.toString()).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d(
          "finishStopPoint() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          getOrderDetail(orderItem.value?.allocId);
          await setDriverClick("85", data.eAddr,"N");
          app_util.Util.toast("경유지에 도착했습니다.");
        } else {
          app_util.Util.toast(_response.resultMap?["msg"]);
        }
      } else {
        app_util.Util.toast(_response.resultMap?["msg"]);
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e(
              "order_detail_page.dart finishStopPoint() Error Default: ${res?.statusCode} -> ${res?.statusCode} // ${res?.statusMessage} // ${res}");
          openOkBox(context, "${res?.statusCode} / ${res?.statusMessage}", Strings.of(context)?.get("confirm") ?? "Error!!", () {
            Navigator.of(context).pop(false);
          });
          break;
        default:
          logger.e("order_detail_page.dart finishStopPoint() Error Default:");
          break;
      }
    });
  }

  Future<void> beginStartPoint(StopPointModel data) async {
    await set_EP_SP("SP");
    var app = await controller.getUserInfo();
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).beginStartPoint(app.authorization, data.orderId, data.stopSeq.toString()).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d(
          "beginStartPoint() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          await getOrderDetail(orderItem.value?.allocId);
          await setDriverClick("84", data.eAddr,"N");
          if(data.finishYn == "N") app_util.Util.toast("경유지에서 출발합니다.");
        } else {
          app_util.Util.toast(_response.resultMap?["msg"]);
        }
      } else {
        app_util.Util.toast(_response.resultMap?["msg"]);
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart beginStartPoint() Error Default: ${res?.statusCode} -> ${res?.statusCode} // ${res?.statusMessage} // ${res}");
          openOkBox(context, "${res?.statusCode} / ${res?.statusMessage}", Strings.of(context)?.get("confirm") ?? "Error!!", () {
            Navigator.of(context).pop(false);
          });
          break;
        default:
          logger.e("order_detail_page.dart beginStartPoint() Error Default:");
          break;
      }
    });
  }

  Future<void> set_EP_SP(String code) async {
    var app = await App().getUserInfo();
    AppDataBase db = App().getRepository();
    String? vehicId = app.vehicId;

    GeofenceModel? removeGeo = await db.getRemoveGeo(vehicId, orderItem.value?.orderId, code);
    if(removeGeo != null) {
      await db.delete(removeGeo);
    }
  }

  Widget getStopPointFuture() {
    final orderService = Provider.of<OrderService>(context);
    return FutureBuilder(
        future: orderService.getStopPoint(context,orderItem.value?.orderId),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            _setState();
            return setStopPointPanel(snapshot);
          }else if(snapshot.hasError){
            return Container(
              padding: EdgeInsets.only(top: CustomStyle.getHeight(40.0)),
              alignment: Alignment.center,
              child: Text(
                  "${Strings.of(context)?.get("empty_list")}",
                  style: CustomStyle.baseFont()),
            );
          }
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              backgroundColor: styleGreyCol1,
            ),
          );
        }
    );
  }

  Widget setDropOffWidget() {
    return Container();
  }

  Widget getNaviBtn() {
    return Container(
      padding: EdgeInsets.only(top: CustomStyle.getHeight(10.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
              onTap: (){
                naviCheck("S");
              },
              child: Container(
                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(30.0 )),
                decoration: CustomStyle.customBoxDeco(sub_color,radius: styleRadius5),
                child: Row(
                  children: [
                    Text(
                      Strings.of(context)?.get("order_detail_start_nevi")??"Not Found",
                      style: CustomStyle.CustomFont(styleFontSize12, styleWhiteCol),
                    ),
                    CustomStyle.sizedBoxWidth(5.0),
                    Icon(Icons.location_on,color: styleWhiteCol,)
                  ],
                ),
              )
          ),
          InkWell(
              onTap: (){
                naviCheck("E");
              },
              child: Container(
                padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(30.0 )),
                decoration: CustomStyle.customBoxDeco(sub_color,radius: styleRadius5),
                child: Row(
                  children: [
                    Text(
                      Strings.of(context)?.get("order_detail_end_nevi")??"Not Found",
                      style: CustomStyle.CustomFont(styleFontSize12, styleWhiteCol),
                    ),
                    CustomStyle.sizedBoxWidth(5.0),
                    Icon(Icons.location_on,color: styleWhiteCol,)
                  ],
                ),
              )
          )
        ],
      ),
    );
  }

  Widget getAllocStateAndPayType() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              orderItem.value?.allocStateName??"-",
              style: CustomStyle.CustomFont(styleFontSize14, app_util.Util.getOrderStateColor(orderItem.value?.allocState)),
            ),
            orderItem.value?.sellCustId == "C20210802130835001" ?
              orderItem.value?.taxinvYn == "N" ?
                orderItem.value?.allocState == "05" && app_util.Util.ynToBoolean(orderItem.value?.payType)?
                InkWell(
                    onTap: () async {
                      goToPay();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                      decoration: tvPay.value ? CustomStyle.customBoxDeco(styleWhiteCol,border_color: text_color_02) : CustomStyle.customBoxDeco(sub_color),
                      child: Text(
                        Strings.of(context)?.get("pay_title")??"Not Found",
                        style: CustomStyle.CustomFont(styleFontSize10, tvPay.value ? text_color_02 : styleWhiteCol),
                      ),
                    )
                ): const SizedBox()
              :const SizedBox()
            : const SizedBox()
          ],
        )
    );
  }

  Widget getMixAndReturnYN() {
    return Container(
        margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.0)),
        alignment: Alignment.centerLeft,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Text(
                "${orderItem.value?.returnYn == "Y"?"왕복":"편도"}  /  ${orderItem.value?.mixYn == "Y"?"혼적":"독차"}",
                style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
              ),
              orderItem.value?.allocState == "05"?
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    InkWell(
                      onTap: () async {
                        await goToReceipt();
                      },
                      child: Container(
                          decoration: tvReceipt.value ? CustomStyle.customBoxDeco(styleWhiteCol,border_color: text_color_02) : CustomStyle.customBoxDeco(sub_color),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                          child:Text(
                            Strings.of(context)?.get("receipt_reg_title")??"Not Found",
                            style: CustomStyle.CustomFont(styleFontSize10, tvReceipt.value ? text_color_02 : styleWhiteCol),
                          )
                      ),
                    ),
                    orderItem.value?.reqPayYN == "N" ?
                      orderItem.value?.chargeType == "01" ?
                        Container(
                           margin: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                           child: InkWell(
                           onTap: () async {
                             await goToTax();
                           },
                           child: Container(
                               decoration: tvTax.value ? CustomStyle.customBoxDeco(styleWhiteCol,border_color: text_color_02) : CustomStyle.customBoxDeco(sub_color),
                               padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                               child:Text(
                                 Strings.of(context)?.get("tax_title")??"Not Found",
                                 style: CustomStyle.CustomFont(styleFontSize10, tvTax.value ? text_color_02 : styleWhiteCol),
                               )
                           ),
                         )
                       ) : const SizedBox()
                     : const SizedBox()
                  ]
              ) : const SizedBox()
            ]
        )
    );
  }

  Widget getPayType(){
    return app_util.Util.ynToBoolean(orderItem.value?.payType)?
    Container(
      margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Text(
            "빠른지급",
            style: CustomStyle.CustomFont(styleFontSize12, order_state_09, font_weight: FontWeight.w500),
          )
        ],
      ),
    ):const SizedBox();
  }

  Widget getOrderInfo() {
    return Container(
      margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              decoration: BoxDecoration(
                border: CustomStyle.borderAllBase(width: CustomStyle.getWidth(1.0)),
              ),
              child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                )
                            )
                        ),
                        child: Text(
                          "화물정보",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                        )
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        orderItem.value?.goodsName??"",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                      ),
                    )
                  ]
              )
          ),
          Container(
              decoration: BoxDecoration(
                border: CustomStyle.borderAllBase(width: CustomStyle.getWidth(1.0)),
              ),
              child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                )
                            )
                        ),
                        child: Text(
                          "요청사항",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                        )
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        orderItem.value?.driverMemo?.isEmpty != true? orderItem.value?.driverMemo??"-" :"-",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                      ),
                    )
                  ]
              )
          ),
        ],
      ),
    );
  }

  Widget getCargoesStateAndTime(String _type) {
    return Container(
      margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.0)),
      child: Row(
        children: [
          Container(
              decoration: CustomStyle.customBoxDeco(styleWhiteCol,border_color:  orderItem.value?.allocState == "04"|| orderItem.value?.allocState == "05" || orderItem.value?.allocState == "20"? text_color_01:sub_color),
              padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
              margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
              child: Text(
                orderItem.value != null ? _type == "wayon" ? Strings.of(context)?.get("order_way_on")??"Not Found":Strings.of(context)?.get("order_way_off")??"Not Found" : "-",
                style: CustomStyle.CustomFont(styleFontSize10, orderItem.value?.allocState == "04"|| orderItem.value?.allocState == "05" || orderItem.value?.allocState == "20" ? text_color_01 : sub_color),
              )
          ),
          Text(
            orderItem.value.isNull ? "-":app_util.Util.splitSDate(_type == "wayon"?orderItem.value?.sDate:orderItem.value?.eDate)??"",
            style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
          )
        ],
      ),
    );
  }

  Widget getWayCargoesInfo(String _type){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children :[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(CustomStyle.getWidth(20.0),CustomStyle.getHeight(5.0),CustomStyle.getWidth(20.0),CustomStyle.getWidth(0.0)),
            child: Wrap(
              spacing: 5,
              runSpacing: 1,
              children: [
                (_type == "wayon"?orderItem.value?.sComName:orderItem.value?.eComName)?.isEmpty == false?
                Text(
                  "${_type == "wayon"?orderItem.value?.sComName:orderItem.value?.eComName}  ",
                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                  overflow: TextOverflow.ellipsis,
                ):const SizedBox(),
                (_type == "wayon"?orderItem.value?.sStaff:orderItem.value?.eStaff)?.isEmpty == false?
                Text(
                  "/  ${_type == "wayon" ? orderItem.value?.sStaff : orderItem.value?.eStaff}  ",
                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                  overflow: TextOverflow.ellipsis,
                ): const SizedBox(),
                (_type == "wayon" ? orderItem.value?.sTel : orderItem.value?.eTel)?.isEmpty == false?
                InkWell(
                    onTap: () async {
                      if(io.Platform.isAndroid) {
                        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                        AndroidDeviceInfo info = await deviceInfo.androidInfo;
                        if (info.version.sdkInt >= 23) {
                          await PhoneCall.calling("${_type == "wayon" ? orderItem.value?.sTel : orderItem.value?.eTel}");
                        }else{
                          await launch("tel://${_type == "wayon" ? orderItem.value?.sTel : orderItem.value?.eTel}");
                        }
                      }else{
                        await launch("tel://${_type == "wayon" ? orderItem.value?.sTel : orderItem.value?.eTel}");
                      }
                    },
                    child: Text(
                      "/  ${_type == "wayon" ? orderItem.value?.sTel : orderItem.value?.eTel}",
                      style: CustomStyle.CustomFont(styleFontSize12, sub_color),
                    )
                ): const SizedBox()
              ],
            ),
          ),

          Container(
              padding:EdgeInsets.only(top: CustomStyle.getHeight(5.0),left: CustomStyle.getWidth(20.0)),
              child: Text(
                  "${_type == "wayon" ? orderItem.value?.sAddr : orderItem.value?.eAddr}",
                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01)
              )
          ),

          (_type == "wayon" ? orderItem.value?.sAddrDetail : orderItem.value?.eAddrDetail)?.isEmpty == false? Container(
              padding:EdgeInsets.only(top: CustomStyle.getHeight(5.0),left: CustomStyle.getWidth(20.0)),
              child: Text(
                  "${_type == "wayon" ? orderItem.value?.sAddrDetail : orderItem.value?.eAddrDetail}",
                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01)
              )
          ): const SizedBox(),

          _type == "wayon" ? Row(
              children: [
                Expanded(
                    flex: 1,
                    child:ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20" && orderItem.value?.allocState != "12"? sub_color : text_color_02,
                          backgroundColor: orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20" && orderItem.value?.allocState != "12"? sub_color : text_color_02,
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5.0))
                          ),
                        ),
                        onPressed: () {
                          if(orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20") showEnterOrder();
                        },
                        child: Text(
                          orderItem.value?.allocState == "04"? "입차 ${orderItem.value?.enterDate?.isNotEmpty == true && orderItem.value?.enterDate !=null ?"(${app_util.Util.getDateStrToStr(orderItem.value?.enterDate, "MM.dd HH:mm")})":""}"
                              : orderItem.value?.allocState == "05"? "입차 ${orderItem.value?.enterDate?.isNotEmpty == true && orderItem.value?.enterDate !=null ?"(${app_util.Util.getDateStrToStr(orderItem.value?.enterDate, "MM.dd HH:mm")})":""}"
                              : orderItem.value?.allocState == "12"? "입차 ${orderItem.value?.enterDate?.isNotEmpty == true && orderItem.value?.enterDate !=null ?"(${app_util.Util.getDateStrToStr(orderItem.value?.enterDate, "MM.dd HH:mm")})":""}"
                              : Strings.of(context)?.get("order_enter")??"Not Found",
                          style: CustomStyle.loginTitleFont(),
                        )
                    )
                ),
                const SizedBox(width: 10),
                Expanded(
                    flex: 1,
                    child:ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20"? sub_color : text_color_02,
                          backgroundColor: orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20"? sub_color : text_color_02,
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5.0))
                          ),
                        ),
                        onPressed: () {
                          if(orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20") showStartOrder();
                        },
                        child: Text(
                          orderItem.value?.allocState == "04"? "출발 (${app_util.Util.getDateStrToStr(orderItem.value?.startDate, "MM.dd HH:mm")})"
                              : orderItem.value?.allocState == "05"? "출발 (${app_util.Util.getDateStrToStr(orderItem.value?.startDate, "MM.dd HH:mm")})"
                              : Strings.of(context)?.get("order_start")??"Not Found",
                          style: CustomStyle.loginTitleFont(),
                        )
                    )
                )
              ]) : ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: orderItem.value?.allocState != "05" ? sub_color : text_color_02,
                backgroundColor: orderItem.value?.allocState != "05" ? sub_color : text_color_02,
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))
                ),
              ),
              onPressed: () {
                if(orderItem.value?.allocState == "04"){
                  showEndOrder();
                }else{
                  app_util.Util.toast("상차 진행중에는 도착처리가 불가능합니다.");
                }
              },
              child: Text(
                orderItem.value?.allocState == "05"?
                "도착 (${app_util.Util.getDateStrToStr(orderItem.value?.finishDate, "MM.dd HH:mm")})"
                    :Strings.of(context)?.get("order_end")??"Not Found",
                style: CustomStyle.loginTitleFont(),
              )
          ),
          CustomStyle.sizedBoxHeight(CustomStyle.getHeight(10.0))
        ]
    );
  }

  Future<void> initView() async {
    setCalcView();
    _setState();
    if(code != null) {
      switch(code) {
        case Const.DEEP_LINK_RECEIPT:
          code = null;
          await goToReceipt();
          break;
        case Const.DEEP_LINK_TAX:
          code = null;
          await goToTax();
          break;
      }
      code = null;
    }
  }


  void setCalcView() {
    tvReceipt.value = !(orderItem.value?.receiptYn == "N");

    if(!(orderItem.value?.taxinvYn == "N")) {
      tvTax.value = true;
    }else{
      tvTax.value = !(orderItem.value?.loadStatus == "0");
    }
    if(orderItem.value?.finishYn == "Y"){
      tvPay.value = true; // true시 tvPay Enable처리
    }else{
      if(app_util.Util.ynToBoolean(orderItem.value?.reqPayYN)) {
        tvPay.value = true;
      }else{
        tvPay.value = !(orderItem.value?.loadStatus == "0");
      }
    }
  }

  Future<void> goToPay() async {
    Logger logger = Logger();
    var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
    if(guest){
      showGuestDialog();
      return;
    }
    await pr?.show();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).getOrderList2(app.authorization, orderItem.value?.allocId, orderItem.value?.orderId).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      await pr?.hide();
      logger.d("goToPay() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        var list;
        list = _response.resultMap?["data"] as List;
        if(list != null && list.isNotEmpty) {
          OrderModel? gData = OrderModel.fromJSON(list[0]);
          if(gData?.finishYn == "N") {
            if(!tvPay.value) {
              if (app.bankchkDate == null) {
                app_util.Util.snackbar(context, "계좌정보를 확인해 주세요. 등록된 계좌정보가 없거나 확인되지 않은 계좌입니다.");
              } else {
                showPay(showPayConfirm);
                await getPopUpTask();
              }
            }else{
              if(!(gData.loadStatus == "0")) {
                if(!(gData.reqPayYN == "N")) {
                  showFastClear();
                }else{
                  showFastGoing();
                }
              }else if(!(gData.reqPayYN == "N")) {
                showFastClear();
              }
            }
          }else{
            showNotFast();
          }
        }else{
          showNotDetail();
        }
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart goToPay() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart goToPay() Error Default:");
          break;
      }
    });

  }

  void showFastClear() {
    openOkBox(context, "빠른지급신청이 완료되었습니다.", Strings.of(context)?.get("confirm")??"Error!!", () { Navigator.of(context).pop(false);});
  }

  void showFastGoing() {
    openOkBox(context, "빠른지급신청 진행 중 입니다.", Strings.of(context)?.get("confirm")??"Error!!", () { Navigator.of(context).pop(false);});
  }

  void showNotFast() {
    openOkBox(context, "해당 오더는 마감처리가 완료된 건으로 \n 빠른지급 신청이 불가합니다.", Strings.of(context)?.get("confirm")??"Error!!", () { Navigator.of(context).pop(false);});
  }

  void showNotDetail() {
    openOkBox(context,"삭제된 오더입니다.", Strings.of(context)?.get("confirm")??"Not Found", () { Navigator.of(context).pop(false);});
  }

  Future<void> showPayConfirm(Map<String,String>? _result) async {
    if(_result?["result"] == "200") {
      var result = await checkBankDate();
      var validation_y_check = await validation_finishYn();
      if(validation_y_check == "N"){
        // 계좌정보가 30일 이내로 업데이트 되었다면 계좌 정보를 체크하지 않음
        if(result != true) {
          //await sendSmartroMid(); // MID 가져오기 API 대기 2024.08.07
          await sendPay(_result);
        }else{
          await checkAccNm(_result);
        }
      }else if(validation_y_check == "Y") {
        openOkBox(context, "해당 오더는 마감처리 또는 빠른지급 신청이 완료된 건으로 \n 빠른지급 신청이 불가합니다.", Strings.of(context)?.get("confirm")??"Error!!", () { Navigator.of(context).pop(false);});
      }else if(validation_y_check == "error" || validation_y_check == "non") {
        openOkBox(context, "빠른지급 신청 중 오류가 발생하였습니다.", Strings.of(context)?.get("confirm")??"Error!!", () { Navigator.of(context).pop(false);});
      }
    }
  }

  Future<String> validation_finishYn() async {
    var result = "non";
    Logger logger = Logger();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).getOrderList2(app.authorization, orderItem.value?.allocId, orderItem.value?.orderId).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("validation_finishYn() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {

          var list = _response.resultMap?["data"] as List;
          List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
          if(itemsList.isNotEmpty) {
            if(itemsList[0].finishYn == "N" && itemsList[0].reqPayYN == "N") {
              result = "N";
            }else{
              result = "Y";
            }
            orderItem.value = itemsList[0];
            setCalcView();
          }
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart validation_finishYn() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          result = "error";
          break;
        default:
          logger.e("order_detail_page.dart validation_finishYn() Error Default:");
          result = "error";
          break;
      }
    });
    return result;
  }

  Future<void> sendSmartroMid(Map<String,String>? _result) async {
    Logger logger = Logger();
    var app = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).sendSmartroMid(app.authorization,widget.item?.sellCustId,widget.item?.sellDeptId,app.driverId,app.vehicId,app.ceo,app.mobile,app.socNo,app.driverEmail,app.bizNum,app.bizName,app.bankCode,app.bankAccount,app.bankCnnm,app.bizAddr,app.bizAddrDetail,app.bizPost).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      if(_response.status == "200") {
        await sendPay(_result);
      }else{
        app_util.Util.toast(_response.message);
      }

    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart sendSmartroMid() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart sendSmartroMid() Error Default:");
          break;
      }
    });

  }

  Future<void> sendPay(Map<String,String>? _result) async {
    Logger logger = Logger();
    var app = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).sendPay(app.authorization, app.vehicId, orderItem.value?.orderId, orderItem.value?.allocId).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      if(_response.status == "200") {
        orderItem.value?.reqPayYN = "Y";
        setCalcView();
        await updateUser(_result);
        app_util.Util.toast("빠른지급 신청이 완료되었습니다.");
        if(orderItem.value?.receiptYn == "N") {
          await showNextReceiptDialog();
        }
      }else{
        app_util.Util.toast(_response.message);
      }

    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart getIaccNm() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart getIaccNm() Error Default:");
          break;
      }
    });

  }

  Future<void> updateUser(Map<String,String>? _result) async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).updateUser(app.authorization, app.vehicId, app.bizName, app.bizNum,app.subBizNum, app.ceo, app.bizPost,app.bizAddr,app.bizAddrDetail,_result?['socNo']?.replaceAll('.', ''),
        app.bizCond, app.bizKind, _result?["email"], app.carTypeCode, app.carTonCode, app.cargoBox, app.dangerGoodsYn, app.chemicalsYn, app.foreignLicenseYn, app.forkliftYn).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("updateUser() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          app.socNo = _result?["socNo"]?.replaceAll('.', '');
          app.driverEmail = _result?["email"];
          await controller.setUserInfo(app);
        }else{
          app_util.Util.toast(_response.resultMap?["msg"]);
        }
      }else{
        app_util.Util.toast(_response.message);
      }
      setState(() {});
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart updateUser() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart updateUser() Error Default:");
          break;
      }
    });
  }

  Future<void> showNextReceiptDialog() async {
    openCommonConfirmBox(
        context,
        "이어서 인수증을 등록하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          await goToReceipt();
          //Navigator.of(context).pop(false);
        }
    );
  }

  Future<void> checkAccNm(Map<String,String>? _result) async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).checkAccNm(app.authorization, app.vehicId, app.bankCode, app.bankAccount,app.bankCnnm).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      if(_response.status == "200") {
        updateBank(_result);
      }else{
        app_util.Util.toast(_response.message);
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart checkAccNm() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart checkAccNm() Error Default:");
          break;
      }
    });
  }

  Future<void> updateBank(Map<String,String>? _result) async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).updateBank(app.authorization, app.bankCode, app.bankCnnm, app.bankAccount).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("updateBank() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        UserModel user = await App().getUserInfo();
        //user.bankchkDate = app_util.Util.getDateCalToStr(DateTime.now(), "yyyy-MM-dd HH:mm:ss");
        user.bankchkDate = app_util.Util.getCurrentDate("yyyy-MM-dd HH:mm:ss");
        App().setUserInfo(user);
        //await sendSmartroMid(); // MID 가져오기 API 대기 2024.08.07
        await sendPay(_result);
        setState(() {});
      }else{
        app_util.Util.toast(_response.message);
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart updateBank() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart updateBank() Error Default:");
          break;
      }
    });
  }

  Future<bool?> checkBankDate() async {
    UserModel? user = await controller.getUserInfo();
    String? nowDate = app_util.Util.getCurrentDate("yyyyMMdd");
    String? saveDate = app_util.Util.getDateStrToStr(user?.bankchkDate, "yyyyMMdd");
    return app_util.Util.betweenDate(nowDate, saveDate)! > 30;
  }

  Future<void> showPay(Function(Map<String,String>?) _showPayCallback) async {
    _isChecked.value = false;
    final sellChargeFix = (int.parse(orderItem.value.sellCharge??"0") * 1.1).toInt().toString().obs;
    TextEditingController socNoController = TextEditingController();
    socNoController.text =  app_util.Util.getSocNumStrToStr(app.value.socNo)??"";
    TextEditingController emailController = TextEditingController();
    emailController.text = app.value.driverEmail??"";

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {

          String fee = app_util.Util.getPayFee(sellChargeFix.value, 1.298);
          String charge = app_util.Util.getInCodeCommaWon(app_util.Util.getPayCharge(sellChargeFix.value, fee));

          return AlertDialog(
              contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
              titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0))
              ),
              title: Container(
                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0),horizontal: CustomStyle.getWidth(15.0)),
                  decoration: CustomStyle.customBoxDeco(main_color,radius: 0),
                  child: Text(
                    '${Strings.of(context)?.get("pay_title")}',
                    style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                  )
              ),

              content: Column(
              children: [
                Obx((){
                  return Expanded(
                    child: SingleChildScrollView(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap:(){
                                  _isChecked.value = !_isChecked.value;
                                },
                                child: Container(
                                    padding:EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5)),
                                    margin: EdgeInsets.only(top: CustomStyle.getHeight(10.0),left: CustomStyle.getWidth(10), right: CustomStyle.getWidth(10)),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(color: _isChecked.value ? sub_color : light_gray23),
                                      color: light_gray24
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "일반운임",
                                                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01,font_weight: FontWeight.w700),
                                                  ),
                                                ],
                                              ),
                                              Obx(() =>
                                              Container(
                                                margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                                child: Text(
                                                  "${app_util.Util.getInCodeCommaWon(sellChargeFix.value)}원",
                                                  style: CustomStyle.CustomFont(styleFontSize16, text_color_01,font_weight: FontWeight.w700),
                                                )
                                              )
                                              ),
                                            ],
                                          ),
                                        Icon(Icons.arrow_downward_outlined),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "빠른운임",
                                                  style: CustomStyle.CustomFont(styleFontSize14, addr_zip_no,font_weight: FontWeight.w700),
                                                ),
                                                Text(
                                                  " (수수료 ${app_util.Util.getInCodeCommaWon(app_util.Util.getPayFee(sellChargeFix.value, 1.298))}원 제외)",
                                                  style: CustomStyle.CustomFont(styleFontSize10, addr_zip_no),
                                                ),
                                              ],
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(left: CustomStyle.getWidth(5)),
                                                child: Text(
                                                  "$charge 원",
                                                  style: CustomStyle.CustomFont(styleFontSize16, addr_zip_no,font_weight: FontWeight.w700),
                                                )
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                    ])
                                )
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10)),
                                child: Row(
                                  children: [
                                    Row(children :[
                                      Text(
                                        "동의",
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01,font_weight: FontWeight.w700),
                                      ),
                                      Checkbox(
                                          value: _isChecked.value,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (value) {
                                            setState(() {
                                              _isChecked.value = !_isChecked.value;
                                            });
                                          }
                                      )
                                    ]),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "* 위 금액은 부가세가 포함된 가격입니다.",
                                          style: CustomStyle.CustomFont(styleFontSize11, addr_zip_no,font_weight: FontWeight.w600),
                                        ),
                                        Text(
                                          "* 왼쪽의 빠른지급신청에 동의해주세요.",
                                          textAlign: TextAlign.start,
                                          style: CustomStyle.CustomFont(styleFontSize11, addr_zip_no,font_weight: FontWeight.w600),
                                        ),
                                        Text(
                                          "* 산재금액(${app_util.Util.getInCodeCommaWon(orderItem.value.insureAmt)} 원) 예치금에서 공제됩니다.",
                                          textAlign: TextAlign.start,
                                          style: CustomStyle.CustomFont(styleFontSize11, addr_zip_no,font_weight: FontWeight.w600),
                                        )
                                      ],
                                    )
                                  ]
                                )
                              ),
                              CustomStyle.sizedBoxHeight(CustomStyle.getHeight(10.0)),
                              Container(
                                  padding:EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                                  child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "신청정보",
                                              style: CustomStyle.CustomFont(styleFontSize15, text_color_01,font_weight: FontWeight.w600),
                                            ),
                                            Text(
                                              "(*아래 정보는 모두 필수 정보입니다.)",
                                              style: CustomStyle.CustomFont(styleFontSize8, text_color_01),
                                            ),
                                          ]
                                        ),
                                        InkWell(
                                            onTap: () async {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => AppBarMyPage(code:"edit_biz",onCallback: onCallback,)));
                                            },
                                            child: Container(
                                                decoration: CustomStyle.customBoxDeco(sub_color),
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                                                child:Text(
                                                    "개인정보변경",
                                                    style: CustomStyle.CustomFont(styleFontSize10, styleWhiteCol)
                                                )
                                            )
                                        ),
                                      ]
                                  )
                              ),
                              Container(
                              margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                border: CustomStyle.borderAllBase(),
                              ),
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: const EdgeInsets.all(5.0),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                        right: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "대표자",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                ),
                                              )
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  padding: const EdgeInsets.all(5.0),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                      )
                                                  ),
                                                  child: Text(
                                                    "${app.value.ceo??""} ",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                height: CustomStyle.getHeight(35),
                                                padding: const EdgeInsets.all(5.0),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                        right: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "생년월일",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                ),
                                              )
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  height: CustomStyle.getHeight(35),
                                                  //padding: const EdgeInsets.all(7.0),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                      )
                                                  ),
                                                  child: TextField(
                                                    maxLines: 1,
                                                    keyboardType: TextInputType.datetime,
                                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                                    textAlignVertical: TextAlignVertical.center,
                                                    textAlign: TextAlign.center,
                                                    controller: socNoController,
                                                    decoration: socNoController.text.isNotEmpty ? InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "생년월일을 입력해주세요.",
                                                      hintStyle: CustomStyle.CustomFont(styleFontSize12, light_gray23),
                                                      suffixIcon: IconButton(
                                                        onPressed: () {
                                                          socNoController.clear();
                                                        },
                                                        icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                                                      ),
                                                    ) : InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "생년월일을 입력해주세요.",
                                                      hintStyle: CustomStyle.CustomFont(styleFontSize12, light_gray23),
                                                    ),
                                                    onChanged: (socNoText) {
                                                      if (socNoText.isNotEmpty) {
                                                        if(socNoController.text.replaceAll(".","").length > 6) {
                                                           String subText = socNoText.replaceAll(".", "").substring(0,6);
                                                           socNoController.text = app_util.Util.getSocNumStrToStr(subText)!;
                                                           app_util.Util.toast("생년월일은 6자리를 넘길 수 없습니다.");
                                                        }else{
                                                          socNoController.text = app_util.Util.getSocNumStrToStr(socNoText.replaceAll(".", ""))!;
                                                          socNoController.selection = TextSelection.fromPosition(TextPosition(offset: socNoController.text.length));
                                                        }
                                                      } else {
                                                        socNoController.text = "";
                                                      }
                                                      setState(() {});
                                                    },
                                                  )

                                                  /*Text(
                                                    "${app_util.Util.getSocNumStrToStr(app.value.socNo)}",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  )*/
                                              )
                                          )
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: const EdgeInsets.all(6.0),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                        right: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "전화번호",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                ),
                                              )
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  padding: const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                      )
                                                  ),
                                                  child: Text(
                                                    "${app_util.Util.makePhoneNumber(app.value.mobile)}",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                height: CustomStyle.getHeight(35),
                                                padding: const EdgeInsets.all(5.0),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                        right: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "이메일",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                ),
                                              )
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  height: CustomStyle.getHeight(35),
                                                  //padding: const EdgeInsets.all(7.0),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                      )
                                                  ),
                                                  child:
                                                  TextField(
                                                    maxLines: 1,
                                                    keyboardType: TextInputType.emailAddress,
                                                    style: CustomStyle.CustomFont(styleFontSize12, Colors.black),
                                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                                    textAlignVertical: TextAlignVertical.center,
                                                    textAlign: TextAlign.center,
                                                    controller: emailController,
                                                    decoration: emailController.text.isNotEmpty ? InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "이메일을 입력해주세요.",
                                                      hintStyle: CustomStyle.CustomFont(styleFontSize12, light_gray23),
                                                      suffixIcon: IconButton(
                                                        onPressed: () {
                                                          emailController.clear();
                                                        },
                                                        icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                                                      ),
                                                    ) : InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "이메일을 입력해주세요.",
                                                      hintStyle: CustomStyle.CustomFont(styleFontSize12, light_gray23),
                                                    ),
                                                    onChanged: (emailText) {
                                                      if (emailText.isNotEmpty) {
                                                        emailController.selection = TextSelection.fromPosition(TextPosition(offset: emailController.text.length));
                                                        emailController.text = emailText;
                                                      } else {
                                                        emailController.text = "";
                                                      }
                                                      setState(() {});
                                                    },
                                                  )
                                                  /*Text(
                                                    "${app.value.driverEmail}",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  )*/
                                              )
                                          )
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: const EdgeInsets.all(5.0),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                        right: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "사업자번호",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                ),
                                              )
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  padding: const EdgeInsets.all(7.0),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                      )
                                                  ),
                                                  child: Text(
                                                    "${app_util.Util.makeBizNum(app.value.bizNum)}",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: const EdgeInsets.all(5.0),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                          color:line,
                                                          width:CustomStyle.getWidth(1.0)
                                                        ),
                                                        right: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "상호명",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                ),
                                              )
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  padding: const EdgeInsets.all(5.0),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: line,
                                                        width: CustomStyle.getWidth(1.0)
                                                      )
                                                    )
                                                  ),
                                                  child: Text(
                                                    "${app.value.bizName}",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                height:CustomStyle.getHeight(45),
                                                padding: const EdgeInsets.all(5.0),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                        right: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "사업자등록주소",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                ),
                                              )
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  height:CustomStyle.getHeight(45),
                                                  padding: const EdgeInsets.all(5.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
                                                      )
                                                  ),
                                                  child: Text(
                                                    "${app.value.bizAddr}",
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                height:CustomStyle.getHeight(45),
                                                padding: const EdgeInsets.all(5.0),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        right: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        )
                                                    )
                                                ),
                                                child: Text(
                                                  "상세주소",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                ),
                                              )
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  height:CustomStyle.getHeight(45),
                                                  padding: const EdgeInsets.all(5.0),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "${app.value.bizAddrDetail}",
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                  ]
                                )
                              ),
                              Container(
                                  padding:EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                                  child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "계좌정보",
                                          style: CustomStyle.CustomFont(styleFontSize15, text_color_01,font_weight: FontWeight.w600),
                                        ),
                                        InkWell(
                                            onTap: () async {
                                              var app = await App().getUserInfo();
                                              ShowBankCheckWidget(context: context,callback: _callback).showBankCheckDialog(app);
                                            },
                                            child: Container(
                                                decoration: CustomStyle.customBoxDeco(sub_color),
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                                                child:Text(
                                                    "계좌정보변경",
                                                    style: CustomStyle.CustomFont(styleFontSize10, styleWhiteCol)
                                                )
                                            )
                                        ),
                                      ]
                                  )
                              ),
                              Container(
                                  margin: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: CustomStyle.borderAllBase(),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding: const EdgeInsets.all(10.0),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          bottom: BorderSide(
                                                              color: line,
                                                              width: CustomStyle.getWidth(1.0)
                                                          ),
                                                          right: BorderSide(
                                                              color: line,
                                                              width: CustomStyle.getWidth(1.0)
                                                          )
                                                      )
                                                  ),
                                                  child: Text(
                                                    "은행명",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  ),
                                                )
                                            ),
                                            Expanded(
                                                flex: 3,
                                                child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color: line,
                                                              width: CustomStyle.getWidth(1.0)
                                                          ),
                                                        )
                                                    ),
                                                    child: Text(
                                                      "${getBankName(app.value.bankCode??"")} ",
                                                      textAlign: TextAlign.center,
                                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                    )
                                                )
                                            )
                                          ]
                                      ),
                                      Row(
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding: const EdgeInsets.all(10.0),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          bottom: BorderSide(
                                                              color: line,
                                                              width: CustomStyle.getWidth(1.0)
                                                          ),
                                                          right: BorderSide(
                                                              color: line,
                                                              width: CustomStyle.getWidth(1.0)
                                                          )
                                                      )
                                                  ),
                                                  child: Text(
                                                    "계좌번호",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  ),
                                                )
                                            ),
                                            Expanded(
                                                flex: 3,
                                                child: Container(
                                                    padding: const EdgeInsets.all(12.0),
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color: line,
                                                              width: CustomStyle.getWidth(1.0)
                                                          ),
                                                        )
                                                    ),
                                                    child: Text(
                                                      "${app.value.bankAccount??"-"} ",
                                                      textAlign: TextAlign.center,
                                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                    )
                                                )
                                            )
                                          ]
                                      ),
                                      Row(
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding: const EdgeInsets.all(10.0),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          right: BorderSide(
                                                              color: line,
                                                              width: CustomStyle.getWidth(1.0)
                                                          )
                                                      )
                                                  ),
                                                  child: Text(
                                                    "예금주",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                  ),
                                                )
                                            ),
                                            Expanded(
                                                flex: 3,
                                                child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Text(
                                                      "${app.value.bankCnnm??"-"} ",
                                                      textAlign: TextAlign.center,
                                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                    )
                                                )
                                            )
                                          ]
                                      ),
                                    ],
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.w)),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children :[
                                        Text(
                                          "위와 같이 로지스링크에",
                                          textAlign: TextAlign.start,
                                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "빠른운임 ",
                                              textAlign: TextAlign.start,
                                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                            ),
                                            Text(
                                              charge,
                                              textAlign: TextAlign.start,
                                              style: CustomStyle.CustomFont(styleFontSize16, addr_zip_no, font_weight: FontWeight.w700),
                                            ),
                                            Text(
                                              " 원을 신청합니다.",
                                              textAlign: TextAlign.start,
                                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                            )
                                          ]
                                        )
                                      ]
                                  )
                              ),
                            ],
                          )
                      )
                    )
                  );
                }),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: InkWell(
                                onTap: (){
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    decoration: CustomStyle.customBoxDeco(cancel_btn,radius: 0),
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0)),
                                    child:Text(
                                      "취소",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                                    )
                                )
                            )
                        ),
                        Expanded(
                            flex: 4,
                            child: InkWell(
                                onTap: (){
                                  confirm(socNoController.text, emailController.text, _showPayCallback);
                                },
                                child: Container(
                                    decoration: CustomStyle.customBoxDeco(main_color,radius: 0),
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0)),
                                    child:Text(
                                      "빠른지급신청",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                                    )
                                )
                            )
                        )
                      ],
                    )
            ])
          );
        }
    );
  }

  void confirm(String? socNoControllerText,String? emailControllerText, Function(Map<String,String>?) _showPayCallback) {
    /*if(app.value.ceo == null || app.value.ceo?.isEmpty == true) {
      app_util.Util.toast("신청정보에 \'대표자\'를 입력해주세요.");
    }else if(app.value.socNo == null || app.value.socNo?.isEmpty == true) {
      app_util.Util.toast("신청정보에 \'생년월일\'를 입력해주세요.");
    }else if(app.value.mobile == null || app.value.mobile?.isEmpty == true) {
      app_util.Util.toast("신청정보에 \'전화번호\'를 입력해주세요.");
    }else if(app.value.driverEmail == null || app.value.driverEmail?.isEmpty == true){
      app_util.Util.toast("신청정보에 \'이메일\'를 입력해주세요.");
    }else if(app.value.bizNum == null || app.value.bizNum?.isEmpty == true) {
      app_util.Util.toast("신청정보에 \'사업자번호\'를 입력해주세요.");
    }else if(app.value.bizName == null || app.value.bizName?.isEmpty == true) {
      app_util.Util.toast("신청정보에 \'상호명\'를 입력해주세요.");
    }else if(app.value.bizPost == null || app.value.bizPost?.isEmpty == true) {
      app_util.Util.toast("신청정보에 \'우편번호\'를 입력해주세요.");
    }else if(app.value.bizAddr == null || app.value.bizAddr?.isEmpty == true) {
      app_util.Util.toast("신청정보에 \'사업자등록주소\'를 입력해주세요.");
    }*/
    if(socNoControllerText == null || socNoControllerText?.isEmpty == true) {
      app_util.Util.toast("신청정보에 \'생년월일\'를 입력해주세요.");
    } else if(emailControllerText == null || emailControllerText?.isEmpty == true){
      app_util.Util.toast("신청정보에 \'이메일\'를 입력해주세요.");
    } else if(!_isChecked.value){
      app_util.Util.toast("빠른지급신청에 동의해주세요.");
    }else {
      Map<String,String> _result = {
        'result' : "200",
        'socNo' : socNoControllerText,
        'email' : emailControllerText
      };
      _showPayCallback(_result);
      Navigator.of(context).pop();
    }
  }

  Future goToReceipt() async {
    var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
    if(guest){
      showGuestDialog();
      return;
    }

    Map<String,int> results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ReceiptPage(item: orderItem.value))
    );

    if(results.containsKey("code")){
      if(results["code"] == 200) {
        await getOrderDetail(orderItem.value?.allocId);
        if (orderItem.value?.taxinvYn == "N" && orderItem.value?.loadStatus == "0") {
          if(orderItem.value?.sellCustId == "C20210802130835001") {
            if(tvTax.value) {
              showNextTaxDialog();
            }
          }else{
            showNextTaxDialog();
          }
        }
        setState(() {});
      }
    }
  }

  void showNextTaxDialog() {
    openCommonConfirmBox(
        context,
        "이어서 전자세금계산서를 발행하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          await goToTax();
        }
    );
  }

  Future<void> goToTax() async {
    var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
    if(guest) {
      showGuestDialog();
      return;
    }
    await getCheckOrderYn();
  }

  Future<void> IntentTax() async {
    var results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TaxPage(item: orderItem.value))
    );

    if(results != null && results.containsKey("code")){
      //print("IntentTax CallBack!! => ${results["code"]}");
      if(results["code"] == 200) {
        app_util.Util.toast("전자세금계산서 발행 신청이 완료되었습니다.");
      }
      await getOrderDetail(orderItem.value?.allocId);
      setState(() {});
    }
  }

  void showAlreadyTax() {
    openOkBox(context,"세금계산서가 이미 처리되었습니다.", Strings.of(context)?.get("confirm")??"Not Found", () => Navigator.of(context).pop(false));
  }

  Future<void> getCheckOrderYn() async {
    Logger logger = Logger();
    await pr?.show();
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).getOrderDetail(app.authorization, orderItem.value?.allocId).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCheckOrderYn() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          var list = _response.resultMap?["data"] as List;
          List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
          if (itemsList.isNotEmpty) {
            if(itemsList[0].taxinvYn == "N"){
              if(tvTax.value) {
                if (itemsList[0].loadStatus == "1") {
                  app_util.Util.toast("전자세금계산서 발행 대기중입니다.");
                } else if (itemsList[0].loadStatus == "2") {
                  app_util.Util.toast("전자세금계산서가 이미 발행되었습니다.");
                }
              }else{
                await IntentTax();
              }
            }else{
              showAlreadyTax();
            }
          } else {

          }
        } else {
          openOkBox(context, _response.resultMap?["msg"], Strings.of(context)?.get("close") ?? "Not Found", () => Navigator.of(context).pop(false));
        }
      } else {
        openOkBox(context, _response.resultMap?["error_message"], Strings.of(context)?.get("close") ?? "Not Found", () => Navigator.of(context).pop(false));
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart getCheckOrderYn() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("order_detail_page.dart getCheckOrderYn() Error Default:");
          break;
      }
    });
  }

  Future<void> getPopUpTask() async {
    Logger logger = Logger();
      await DioService.dioClient(header: true).getCodeList(Const.DRIVER_POPUP_CHECK).then((it) async {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("GetPopUpTask() _response -> ${_response.status} // ${_response.resultMap}");
        if(_response.status == "200") {
          if(_response.resultMap?["data"] != null) {
            var jsonString = jsonEncode(it.response.data);
            Map<String, dynamic> jsonData = jsonDecode(jsonString);
            var list = jsonData?["data"] as List;
            List<CodeModel>? itemsList = list.map((i) => CodeModel.fromJSON(i)).toList();
            if(itemsList[0].useYn == "Y") {
              openOkBox(context, "${itemsList[0].codeName} \n\n ${itemsList[0].memo}", Strings.of(context)?.get("confirm") ?? "Error!!", () async {
                Navigator.of(context).pop(false);
              },align: TextAlign.left);
            }
          }
        }
      }).catchError((Object obj) async {
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            logger.e("brige_page.dart GetPopUpTask() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
            break;
          default:
            logger.e("brige_page.dart GetPopUpTask() Error Default:");
            break;
        }
      });
  }

  Future<void> _setState() async {
    List<String>? allocList = await SP.getStringList(Const.KEY_ALLOC_ID);
    if(orderItem.value?.allocState == "04") {
      finished.value = false;
    }else if(orderItem.value?.allocState == "05") {
      finished.value = true;
      if (allocList != null && allocList.isNotEmpty) {
        allocList.remove(orderItem.value?.allocId);
        await SP.putStringList(Const.KEY_ALLOC_ID, allocList);
      }
    }else if(orderItem.value?.allocState == "20") {
      finished.value = true;
      if (allocList != null && allocList.isNotEmpty) {
        allocList.remove(orderItem.value?.allocId);
        await SP.putStringList(Const.KEY_ALLOC_ID, allocList);
      }
    }else{
      finished.value = false;
    }
  }

  String? getBankName(String? code) {
    return SP.getCodeName(Const.BANK_CD, code!);
  }

  void showGuestDialog(){
    openOkBox(context, Strings.of(context)?.get("Guest_Intro_Mode")??"Error", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
  }

  Future<void> showCancelDialog() async {
    var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
    if(guest) {
      showGuestDialog();
      return;
    }

    openCommonConfirmBox(
        context,
        "오더 취소를 요청하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          await setOrderState("20", "오더 취소를 요청했습니다.");
        });

  }

  void showEnterOrder() {
    if(orderItem.value?.allocState == "01") {
      openCommonConfirmBox(
          context,
          "상차지에서 입차처리하시겠습니까?",
          Strings.of(context)?.get("cancel") ?? "Not Found",
          Strings.of(context)?.get("confirm") ?? "Not Found",
              () => Navigator.of(context).pop(false),
              () async {
            Navigator.of(context).pop(false);
            await setOrderState("12", "상차지 입차 처리했습니다.");
          });
    }else{
      app_util.Util.toast("출발 및 도착 진행중에는 입차처리가 불가능합니다.");
    }
  }

  void showStartOrder() {
    openCommonConfirmBox(
        context,
        "상차지에서 출발하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          await setOrderState("04", "상차지에서 출발했습니다.");
        });
  }

  void showEndOrder() {
    openCommonConfirmBox(
        context,
        "하차지에 도착하셨습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          await setOrderState("05", "하차지에 도착했습니다.");
        });
  }

  Future<void> setDriverClick(String? code, String? addr, String? auto) async {
    Logger logger = Logger();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).setDriverClick(app.authorization, orderItem.value?.orderId, code, addr, auto).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("setDriverClick() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {

      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart setDriverClick() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart setDriverClick() Error Default:");
          break;
      }
    });
  }

  Future<void> addAllocList() async {
    List<String>? allocList = await SP.getStringList(Const.KEY_ALLOC_ID);
    allocList?.add(orderItem.value?.allocId??"");
    await SP.putStringList(Const.KEY_ALLOC_ID, allocList);
    locationUpdate(orderItem.value?.allocId);
  }

  Future<void> getOrderList2(String allocId, String orderId) async {
    Logger logger = Logger();
    await pr?.show();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).getOrderList2(app.authorization, allocId, orderId).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOrderList2() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {

          var list = _response.resultMap?["data"] as List;
          List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i))
              .toList();
          if(itemsList.isNotEmpty) {
            orderItem.value = itemsList[0];
            await initView();
            setState(() {
              List<LatLng> bounds = List.empty(growable: true);
              bounds.add(LatLng(orderItem.value!.sLat!, orderItem.value!.sLon!));
              bounds.add(LatLng(orderItem.value!.eLat!, orderItem.value!.eLon!));

              if(orderItem.value?.sLat.isNull != true || orderItem.value?.sLon.isNull != null) {
                markers.add(Marker(
                    markerId: orderItem.value?.sComName ?? "상차지",
                    markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/2018/pc/flagImg/blue_b.png',
                    latLng: LatLng(orderItem.value!.sLat!, orderItem.value!.sLon!),
                    infoWindowContent: '<div style="font: bold italic 0.5em 돋움체;">${orderItem.value?.sComName ?? "상차지"}</div>'
                ));
              }

              if(orderItem.value?.eLat.isNull != true || orderItem.value?.eLon.isNull != null) {
                markers.add(Marker(
                  markerId: orderItem.value?.eComName??"하차지",
                  markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/2018/pc/flagImg/red_b.png',
                  latLng: LatLng(orderItem.value!.eLat!, orderItem.value!.eLon!),
                  infoWindowContent: '<div style="font: bold italic 0.5em 돋움체;">${orderItem.value?.eComName??"하차지"}</div>',
                ));
              }

              setState(() {
                mapController?.fitBounds(bounds);
                mapController?.setBounds();
              });
            });
          }else{
            openOkBox(context,"삭제된 오더입니다.", Strings.of(context)?.get("confirm")??"Not Found", () { Navigator.of(context).pop(false); Navigator.of(context).pop(false);});
          }
        }else{
          openOkBox(context, _response.resultMap?["msg"], Strings.of(context)?.get("close")??"Not Found", () {Navigator.of(context).pop(false);});
        }
      }else{
        openOkBox(context, _response.resultMap?["error_message"], Strings.of(context)?.get("close")??"Not Found", () { Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart getOrderList2() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart getOrderList2() Error Default:");
          break;
      }
    });
  }

  Future<void> getOrderDetail(String? allocId) async {
    Logger logger = Logger();
    //await pr?.show();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).getOrderDetail(app.authorization, allocId).then((it) async {
      //await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOrderDetail() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          var list = _response.resultMap?["data"] as List;
          if (list.isNotEmpty) {
            List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i))
                .toList();
            orderItem.value = itemsList[0];
            await initView();
          } else {
            openOkBox(context, "삭제된 오더입니다.",
                Strings.of(context)?.get("confirm") ?? "Not Found", () {
                  Navigator.of(context).pop(false);
                  Navigator.of(context).pop(false);
                });
          }
        }else{
          openOkBox(context, _response.resultMap?["msg"], Strings.of(context)?.get("close")??"Not Found", () => Navigator.of(context).pop(false));
        }
      }else{
        openOkBox(context, _response.resultMap?["error_message"], Strings.of(context)?.get("close")??"Not Found", () => Navigator.of(context).pop(false));
      }
    }).catchError((Object obj) async {
      //await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart getOrderDetail() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart getOrderDetail() Error Default:");
          break;
      }
    });
  }

  Future<void> setOrderState(String code, String msg) async {
    Logger logger = Logger();
    await pr?.show();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).setOrderState(app.authorization, orderItem.value?.orderId, orderItem.value?.allocId, code).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("setOrderState() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          if(code == "04") {
            await addAllocList();
            await setDriverClick(code,orderItem.value?.sAddr,"N");
          }else if(code == "05"){
            orderItem.value?.allocState = code;
            await removeAllocList();
            await setDriverClick(code,orderItem.value?.eAddr,"N");
          }
          removeGeofence(code);
          await getOrderDetail(orderItem.value?.allocId);
          app_util.Util.toast(msg);
        }else{
          app_util.Util.toast(_response.resultMap?["msg"]);
        }
      }else{
        app_util.Util.toast(_response.resultMap?["msg"]);
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("order_detail_page.dart setOrderState() Error Default: ${res?.statusCode} -> ${res?.statusCode} // ${res?.statusMessage} // ${res}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("order_detail_page.dart setOrderState() Error Default:");
          break;
      }
    });
  }

  Future<void> removeGeofence(String code) async {
    AppDataBase db = App().getRepository();
    var app = await App().getUserInfo();
    String? vehicId = app.vehicId;
    if(code == "04") {
      GeofenceModel? removeGeo = await db.getRemoveGeo(vehicId, widget.orderId, "S");
      if(removeGeo != null) {
        db.delete(removeGeo);
      }
    }else if(code == "05"){
      GeofenceModel? removeGeo = await db.getRemoveGeo(vehicId, widget.orderId, "E");
      if(removeGeo != null) {
        db.delete(removeGeo);
      }
    }else if(code == "20"){
      db.deleteAll(await db.getRemoveGeoList(app.vehicId, widget.orderId));
    }
    FBroadcast.instance().broadcast(Const.INTENT_GEOFENCE);
  }

  Future<void> removeAllocList() async {
    locationUpdate(orderItem.value?.allocId);

    List<String>? allocList = await SP.getStringList(Const.KEY_ALLOC_ID);
    allocList?.remove(orderItem.value?.allocId);
    await SP.putStringList(Const.KEY_ALLOC_ID, allocList);
  }

  Future<void> locationUpdate(String? allocId) async {
    Logger logger = Logger();
    var lat = await SP.getString(Const.KEY_LAT, "");
    var lon = await SP.getString(Const.KEY_LON, "");
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).locationUpdate(app.authorization, lat,lon,allocId).then((it) {
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
          //print("locationUpdate() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
        //print("locationUpdate() Error Default => ");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = app_util.Util.networkProgress(context);
    //openOkBox(context, msg, Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
    return WillPopScope(
        onWillPop: () async {
          FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
          Navigator.of(context).pop({'code':200});
          return false;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
                child: AppBar(
                  centerTitle: true,
                  title: Text(
                      Strings.of(context)?.get("order_detail_title")??"Not Found",
                      style: CustomStyle.appBarTitleFont(styleFontSize16,styleWhiteCol)
                  ),
                  leading: IconButton(
                    onPressed: (){
                      FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
                      Navigator.of(context).pop({'code':200});
                    },
                    color: styleWhiteCol,
                    icon: const Icon(Icons.arrow_back),
                  ),
                )
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: false,
                    snap: false,
                    floating: true,
                    expandedHeight: CustomStyle.getHeight(300.0),
                    flexibleSpace: FlexibleSpaceBar(
                      title: KakaoMap(
                        onMapCreated: ((controller) async {

                          setState(() {

                            List<LatLng> bounds = List.empty(growable: true);
                            if(orderItem.value?.sLat.isNull != true && orderItem.value?.sLon.isNull != null) {
                              bounds.add(LatLng(orderItem.value!.sLat!, orderItem.value!.sLon!));
                              markers.add(Marker(
                                  markerId: orderItem.value?.sComName ?? "상차지",
                                  markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/2018/pc/flagImg/blue_b.png',
                                  latLng: LatLng(orderItem.value!.sLat!, orderItem.value!.sLon!),
                                  infoWindowContent: '<div style="font: bold italic 0.5em 돋움체;">${orderItem.value?.sComName ?? "상차지"}</div>'
                              ));
                            }

                            if(orderItem.value?.eLat.isNull != true && orderItem.value?.eLon.isNull != null) {
                              bounds.add(LatLng(orderItem.value!.eLat!, orderItem.value!.eLon!));
                              markers.add(Marker(
                                markerId: orderItem.value?.eComName??"하차지",
                                markerImageSrc: 'https://t1.daumcdn.net/localimg/localimages/07/2018/pc/flagImg/red_b.png',
                                latLng: LatLng(orderItem.value!.eLat!, orderItem.value!.eLon!),
                                infoWindowContent: '<div style="font: bold italic 0.5em 돋움체;">${orderItem.value?.eComName??"하차지"}</div>',
                              ));
                            }

                            mapController = controller;
                            mapController?.fitBounds(bounds);
                            mapController?.setBounds();
                          });

                        }),
                        currentLevel: 23,
                        center: LatLng(35.81588719434526, 128.10472746046923),
                        markers: markers.toList(),
                        zoomControl: false,

                        onMarkerTap: (markerId, latLng, zoomLevel) {
                          setState(() {
                            mapController?.setLevel(3);
                            mapController?.panTo(latLng);
                          });
                        },
                      ),
                      titlePadding: const EdgeInsets.all(0.0),
                    ),
                    leading: const SizedBox(),
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index){
                            int? stopCnt = orderItem.value?.stopCount;
                            return Obx((){
                              return Container(
                                  padding: EdgeInsets.all(CustomStyle.getHeight(10.0)),
                                  child: Column(
                                    children: [
                                      // 길안내 버튼
                                      finished.value == false? getNaviBtn() : const SizedBox(),
                                      // 운송 상태 및 지불 방법
                                      getAllocStateAndPayType(),
                                      // 화물 적재 타입 및 운송 타입
                                      getMixAndReturnYN(),
                                      // 빠른 지급
                                      orderItem.value?.sellCustId == "C20210802130835001" ? getPayType() : const SizedBox(),
                                      // 화물 정보 및 요청사항
                                      getOrderInfo(),
                                      // 상차 상태 및 운송 시간
                                      getCargoesStateAndTime("wayon"),
                                      // 운송 상세 정보
                                      getWayCargoesInfo("wayon"),
                                      CustomStyle.getDivider1(),
                                      //경유지 정보
                                      stopCnt.isNull? const SizedBox() : stopCnt! > 0 ? getStopPointFuture():const SizedBox(),
                                      CustomStyle.sizedBoxHeight(CustomStyle.getHeight(10.0)),
                                      getCargoesStateAndTime("wayoff"),
                                      getWayCargoesInfo("wayoff"),
                                      //하차 정보
                                    ],
                                  )
                              );
                            });
                          },
                          childCount: 1
                      )
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SizedBox(
                height: CustomStyle.getHeight(60.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !finished.value == true ? Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await showCancelDialog();
                            },
                            child: Container(
                              height: CustomStyle.getHeight(60.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: cancel_btn
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                Strings.of(context)?.get("order_detail_cancel_driving")??"Not Found",
                                style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                              ),
                            )
                        )
                    ) : SizedBox(),
                    Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: ()  async {
                              var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                              if(guest){
                                showGuestDialog();
                                return;
                              }
                              if(io.Platform.isAndroid) {
                                DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                                AndroidDeviceInfo info = await deviceInfo.androidInfo;
                                if (info.version.sdkInt >= 23) {
                                  await PhoneCall.calling("${orderItem.value?.sellStaffTel}");
                                }else{
                                  await launch("tel://${orderItem.value?.sellStaffTel}");
                                }
                              }else{
                                await launch("tel://${orderItem.value?.sellStaffTel}");
                              }
                            },
                            child: Container(
                              height: CustomStyle.getHeight(60.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: main_color
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                Strings.of(context)?.get("order_detail_call")??"Not Found",
                                style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                              ),
                            )
                        )
                    )
                  ],
                )
            )
        )
    );



  }



}