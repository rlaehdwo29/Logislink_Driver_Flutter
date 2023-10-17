import 'dart:developer';

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:logislink_driver_flutter/page/subPage/receipt_page.dart';
import 'package:logislink_driver_flutter/page/subPage/tax_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/provider/order_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart' as app_util;
import 'package:logislink_driver_flutter/widget/show_bank_check_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class OrderDetailPage extends StatefulWidget {
  OrderModel? item;
  String? allocId,orderId,code;
  OrderDetailPage({Key? key, this.item, this.allocId, this.orderId,this.code}):super(key: key);

  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>{

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
  final platform = const MethodChannel("testing.flutter.android");
  Set<Marker> markers = {};
  final app = UserModel().obs;
  final orderItem = OrderModel().obs;
  final stopPointList = List.empty(growable: true).obs;

  @override
  void initState() {
    FBroadcast.instance().register(Const.INTENT_DETAIL_REFRESH, (value, callback) async {
      await getOrderDetail(widget.allocId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      app.value = await controller.getUserInfo();

      if(widget.item != null) {
        orderItem.value = widget.item!;
        await initView();
      }else{
        if(widget.allocId != null) {
          code = widget.code;
          await getOrderList2();
        }else{
          Navigator.of(context).pop(false);
        }
      }

    });
    super.initState();
  }

  void _callback(String? bankCd, String? acctNm, String? acctNo) async {
      UserModel user = await controller.getUserInfo();
      user.bankCode = bankCd;
      user.bankCnnm = acctNm;
      user.bankAccount = acctNo;
      controller.setUserInfo(user);
      setState(() {});
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
      await platform.invokeMethod('showActivity',values);
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
                            onTap: (){
                              launch("tel://${iData.eTel}");
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
            InkWell(
              onTap: (){
                  goToPay();
              },
              child: orderItem.value?.allocState == "05" && app_util.Util.ynToBoolean(orderItem.value?.payType)?
               Container(
                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                decoration: tvPay.value ? CustomStyle.customBoxDeco(styleWhiteCol,border_color: text_color_02) : CustomStyle.customBoxDeco(sub_color),
                child: Text(
                  Strings.of(context)?.get("pay_title")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize10, tvPay.value ? text_color_02 : styleWhiteCol),
                ),
              ) : const SizedBox()
            )
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
                    margin: EdgeInsets.only(right: CustomStyle.getWidth(10.0)),
                    child:Text(
                        Strings.of(context)?.get("receipt_reg_title")??"Not Found",
                      style: CustomStyle.CustomFont(styleFontSize10, tvReceipt.value ? text_color_02 : styleWhiteCol),
                    )
                  ),
                ),
                orderItem.value?.chargeType == "01" ?
                InkWell(
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
                ):const SizedBox(),
              ]
            ) : const SizedBox()
          ]
        )
    );
  }

  Widget getPayType(){
    return app_util.Util.ynToBoolean(orderItem.value?.payType)? Container(
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
                        onTap: (){
                          launch("tel://${_type == "wayon" ? orderItem.value?.sTel : orderItem.value?.eTel}");
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
                          primary: orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20" && orderItem.value?.allocState != "12"? sub_color : text_color_02,
                          onPrimary: orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20" && orderItem.value?.allocState != "12"? sub_color : text_color_02,
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
                        primary: orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20"? sub_color : text_color_02,
                        onPrimary: orderItem.value?.allocState != "04" && orderItem.value?.allocState != "05" && orderItem.value?.allocState != "20"? sub_color : text_color_02,
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
                  primary: orderItem.value?.allocState != "05" ? sub_color : text_color_02,
                  onPrimary: orderItem.value?.allocState != "05" ? sub_color : text_color_02,
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

  Future<void> showPayConfirm(String? _result) async {
    if(_result == "200") {
      var result = await checkBankDate();
      var validation_y_check = await validation_finishYn();
      if(validation_y_check == "N"){
        if(result != true) {
          await sendPay();
        }else{
          await checkAccNm();
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

  Future<void> sendPay() async {
    Logger logger = Logger();
    var app = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).sendPay(app.authorization, app.vehicId, orderItem.value?.orderId, orderItem.value?.allocId).then((it) async {
    await pr?.hide();
    ReturnMap _response = DioService.dioResponse(it);
    if(_response.status == "200") {
      Navigator.of(context).pop(false);
      orderItem.value?.reqPayYN = "Y";
      setCalcView();
      app_util.Util.toast("빠른지급 신청이 완료되었습니다.");
      if(orderItem.value?.receiptYn == "N") {
        showNextReceiptDialog();
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

  void showNextReceiptDialog() {
    openCommonConfirmBox(
        context,
        "이어서 인수증을 등록하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
              Navigator.of(context).pop(false);
              await goToReceipt();
            }
    );
  }

  Future<void> checkAccNm() async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).checkAccNm(app.authorization, app.vehicId, app.bankCode, app.bankAccount,app.bankCnnm).then((it) async {
    await pr?.hide();
    ReturnMap _response = DioService.dioResponse(it);
      if(_response.status == "200") {
        updateBank();
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

  Future<void> updateBank() async {
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).updateBank(app.authorization, app.bankCode, app.bankCnnm, app.bankAccount).then((it) async {
    await pr?.hide();
    ReturnMap _response = DioService.dioResponse(it);
    if(_response.status == "200") {
      UserModel user = await App().getUserInfo();
      user.bankchkDate = app_util.Util.getDateCalToStr(DateTime.now(), "yyyy-MM-dd HH:mm:ss");
        App().setUserInfo(user);
        await sendPay();
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

  Future<void> showPay(Function(String?) _showPayCallback) async {
    _isChecked.value = false;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {

          String fee = app_util.Util.getPayFee(orderItem.value?.sellCharge, orderItem.value?.reqPayFee);
          String charge = app_util.Util.getInCodeCommaWon(app_util.Util.getPayCharge(orderItem.value?.sellCharge, fee));

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
              content: Obx((){
                return SingleChildScrollView(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding:EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                            margin: EdgeInsets.only(top: CustomStyle.getHeight(10.0)),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "빠른 운임 : $charge원",
                                        style: CustomStyle.CustomFont(styleFontSize12, addr_zip_no),
                                      ),
                                      Text(
                                        "(사용료 ${app_util.Util.getInCodeCommaWon(app_util.Util.getPayFee(orderItem.value?.sellCharge, orderItem.value?.reqPayFee))}원 제외)",
                                        style: CustomStyle.CustomFont(styleFontSize12, addr_zip_no),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    " / ",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(styleFontSize18, text_color_01),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "일반운임 : ${app_util.Util.getInCodeCommaWon(orderItem.value?.sellCharge)}원",
                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                  ),
                                )
                              ],
                            )
                          ),
                          CustomStyle.sizedBoxHeight(CustomStyle.getHeight(10.0)),
                          Container(
                              padding:EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "계좌정보",
                                    style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
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
                              margin: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children :[
                                    Expanded(
                                        flex: 4,
                                        child: Wrap(
                                            direction: Axis.horizontal,
                                            alignment: WrapAlignment.start,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                "위와 같이 로지스링크에 빠른운임 ",
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                              ),
                                              Text(
                                                charge,
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize12, addr_zip_no),
                                              ),
                                              Text(
                                                "원을 신청합니다.",
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                              )
                                            ]
                                        )
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Row(
                                            children:[
                                              Text(
                                                "동의",
                                                style: CustomStyle.CustomFont(styleFontSize10, sub_color),
                                              ),
                                              Checkbox(
                                                  value: _isChecked.value,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _isChecked.value = value!;
                                                    });
                                                  }
                                              )
                                            ]
                                        )
                                    )
                                  ]
                              )
                          ),
                          CustomStyle.sizedBoxHeight(10.0),
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
                                    confirm(_showPayCallback);
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
                        ],
                      )
                  )
                );
              })
            );
        }
    );
  }

  void confirm(Function(String?) _showPayCallback) {
    if(_isChecked.value){
      _showPayCallback("200");
      Navigator.of(context).pop();
    }else{
      app_util.Util.toast("빠른지급신청에 동의해주세요.");
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
          showNextTaxDialog();
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
    locationUpdate(widget.allocId);
  }

  Future<void> getOrderList2() async {
    Logger logger = Logger();
    await pr?.show();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).getOrderList2(app.authorization, widget.allocId, widget.orderId).then((it) async {
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
    locationUpdate(widget.allocId);

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
        backgroundColor: Theme.of(context).backgroundColor,
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
                              getPayType(),
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
                onTap: () async {
                  var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                  if(guest){
                    showGuestDialog();
                    return;
                  }
                  launch("tel://${orderItem.value?.sellStaffTel}");
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