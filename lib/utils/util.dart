import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/notice_model.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:dio/dio.dart';

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../common/config_url.dart';


class Util {

/*  static int convertDpToPx(Context context, int dp) {
    return (dp * (context.getResources().getDisplayMetrics().xdpi / DisplayMetrics.DENSITY_DEFAULT)).round();
  }*/

  static Future<String> encryption(String value) async {

    String file = await rootBundle.loadString('assets/raw/key.txt');
    var b = utf8.encode(file);
    var keyBytes = Uint8List(16);
    String mIv = "";

    for(var i in keyBytes){
      mIv = mIv + i.toString();
    }

    var len = b.length;

    if(len > keyBytes.lengthInBytes) len = keyBytes.length;
    List.copyRange(b,0, keyBytes, 0, len);

    final key = enc.Key.fromUtf8(file);
    final iv = enc.IV.fromUtf8(mIv);

    final encrypter = enc.Encrypter(enc.AES(key,mode: enc.AESMode.cbc,padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(value, iv: iv);
    //var result = await Aespack.encrypt(value, file, mIv);
    return encrypted.base64;
  }

  static Future<String> jumin_aes_Decrypt(String value) async {
    String file = await rootBundle.loadString('assets/raw/key.txt');
    var b = utf8.encode(file);
    var keyBytes = Uint8List(16);
    String mIv = "";

    for(var i in keyBytes){
      mIv = mIv + i.toString();
    }
    var len = b.length;

    if(len > keyBytes.lengthInBytes) len = keyBytes.length;
    List.copyRange(b,0, keyBytes, 0, len);

    final key = enc.Key.fromUtf8(file);
    final iv = enc.IV.fromUtf8(mIv);
    final encrypter = enc.Encrypter(enc.AES(key,mode: enc.AESMode.cbc,padding: 'PKCS7'));
    final encrypted = encrypter.decrypt64(value, iv: iv);
    return encrypted;
  }

  static String booleanToYn(bool value) {
    if (value) {
      return "Y";
    } else {
      return "N";
    }
  }

  static String ynToPay(String? yn) {
    if(yn != null){
      return "지급";
    }else{
      return "미지급";
    }
  }

  static Color getPayYnColor(String? pay) {
    if(pay == null) {
      return order_state_09;
    }else{
      return order_state_04;
    }
  }

  static Future<void> settingInfo() async {
    final controller = Get.find<App>();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    // Device 정보 세팅
    Map<String,dynamic> device = <String, dynamic>{};
    if (Platform.isAndroid) {
      AndroidDeviceInfo info  = await deviceInfo.androidInfo;
      device = {
        "model":info.model,
        "deviceOs": "Android ${info.version.sdkInt}",
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      device = {
        "model":info.name,
        "deviceOs": "${info.systemName} ${info.systemVersion}"
      };
    } else {
      device = {
        "model": Platform.isLinux?"Linux":Platform.isMacOS?"Mac":Platform.isWindows?"Window":"unknown",
        "deviceOs": "unknown"
      };
    }
    controller.device_info.value = device;

    // App 정보 세팅
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String,dynamic> app = {
      "appName":packageInfo.appName,
      "packageName":packageInfo.packageName,
      "version":packageInfo.version,
      "buildNumber":packageInfo.buildNumber
    };
    controller.app_info.value = app;
  }

  static Future<String> getPhoneNum() async {
    String? mobileNumber;
    try {
      String number = (await MobileNumber.mobileNumber)!.substring(2);
      mobileNumber = number.replaceAll("+82", "0");

      print('getPhoneNumber result: $mobileNumber');
      final List<SimCard> simCards = (await MobileNumber.getSimCards)!;
      simCards?.map((sim) => print("Sim Number => ${sim.number} // ${sim.carrierName} // ${sim.countryIso} // ${sim.countryPhonePrefix} // ${sim.displayName} // ${sim.slotIndex}")).toList();
      return mobileNumber;
    } on PlatformException catch (e) {
      print("getPhoneNumber Exception => $e");
      debugPrint("Failed to get mobile number because of '${e.message}'");
      //toast("${e.message}");
      return "";
    }
  }

  static String ynToPossible(String? yn) {
    if (yn != null) {
      return yn == "Y" ? "가능" : "불가";
    } else {
      return "불가";
    }
  }


  static String? makePhoneNumber(String? phone){
    return phone?.replaceAllMapped(RegExp(r'(\d{3})(\d{3,4})(\d{4})'), (m) => '${m[1]}-${m[2]}-${m[3]}');
  }

  static snackbar(BuildContext context, String msg){
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          left: CustomStyle.getWidth(20.0),
          right: CustomStyle.getWidth(20.0),
          bottom: CustomStyle.getHeight(20.0),
        ),
        padding: EdgeInsets.only(
          left: CustomStyle.getWidth(10.0),
          right: CustomStyle.getWidth(10.0),
          top: CustomStyle.getHeight(14.0),
          bottom: CustomStyle.getHeight(14.0),
        ),
        backgroundColor: main_color,
          content: SizedBox(
            child: Text(
              msg,
              style: CustomStyle.whiteFont(),
            ),
          ),
      )
    );
  }

  static toast(String? msg) {
    return Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: text_color_01,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static String makeDistance(num? d) {
    int? result = d?.round();
    if(d == 0) {
      return "";
    }else{
      return "${result}km";
    }
  }

  static String? makeBizNum(String? num) {
    if(num?.isEmpty == true || num == null){
      return "";
    }else{
      return num?.replaceAllMapped(RegExp(r'(\d{3})(\d{1,2})(\d{1,5})'),(Match m) => "${m[1]}-${m[2]}-${m[3]}");
    }
  }

  static String makeTime(int? min) {
    int hour = Duration(minutes: min!).inHours;
    int minute = Duration(minutes: min).inMinutes - Duration(hours: hour).inMinutes;
    String time = "";
    if(hour == 0) {
      time = "$minute분";
    }else{
      time = "$hour시간$minute분";
    }
    return time;
  }

  static Color getOrderStateColor(String? state) {
    switch(state) {
      case "01":
      case "12":
        return order_state_01;
      case "04":
        return order_state_04;
      case "05":
        return order_state_05;
      case "09":
        return order_state_09;
      default:
        return order_state_01;
    }
  }

  static String? makeString(String? _string){
    if(_string == null || _string == ""){
      return "-";
    }
    return _string;
  }

  static bool ynToBoolean(String? value) {
    return value != null ? "Y" == value : false;
  }

  static String? splitSDate(String? date) {
      DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      DateTime? d;
      try{
        d = dateFormat.parse(date!);
      }catch(e) {
        print(e);
      }

      if(DateFormat("HH:mm:ss").format(d!) == "00:00:00") {
        return "${DateFormat("MM.dd").format(d!)} 지금";
      }else{
        return DateFormat("MM.dd HH:mm").format(d!);
      }
  }

  static String? splitEDate(String? date) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime? d;
    try{
      d = dateFormat.parse(date!);
    }catch(e) {
      print(e);
    }

    if(DateFormat("HH:mm:ss").format(d!) == "00:00:00") {
      return "${DateFormat("MM.dd").format(d!)} 당일";
    }else{
      return DateFormat("MM.dd HH:mm").format(d!);
    }
  }

  static num? betweenDate(String? date1, String? date2) {
    Logger logger = Logger();
    DateFormat format = DateFormat("yyyyMMdd");
    int? FirstDate;
    int? SecondDate;
    num? calDateDays = 0;
    try{
      FirstDate = DateTime.parse(date1??"").millisecondsSinceEpoch;
      SecondDate = DateTime.parse(date2??"").millisecondsSinceEpoch;
      int calDate = FirstDate - SecondDate;
      calDateDays = (calDate / (24 * 60 * 60 * 1000)).abs();
    }catch(e){
      print(e);
    }
    return calDateDays;
  }

  static String getDateCalToStr(DateTime? calendar, String? newPatten){
    return DateFormat(newPatten).format(calendar!);
  }

  static String? getCurrentDate(String pattern) {
    return DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
  }

  static String? getDateStrToStr(String? date, String? newPattern) {
    DateTime? d = null;
    try{
      d = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date!);
    }catch(e) {
      print("getDateStrToStr() Error => $e");
    }
    if(d != null) {
      return DateFormat(newPattern).format(d);
    }else{
      return "-";
    }
  }

  static String getInCodeCommaWon(String? won) {
    if (won == null || won.isEmpty) return "0";
    double inValues = double.parse(won);
    NumberFormat Commas = NumberFormat("#,###");
    return Commas.format(inValues);
  }

  static String getPayFee(String? payCharge, double? per) {
    int charge = int.parse(payCharge!);
    int fee = (charge * (per! / 100)).ceil();
    return fee.toString();
  }

  static String getPayCharge(String? charge, String? fee) {
    return (int.parse(charge!) - int.parse(fee!)).toString();
  }

  static ProgressDialog? networkProgress(BuildContext context) {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal,
        isDismissible: false,
        showLogs: false,
        customBody: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(CustomStyle.getWidth(8.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: CustomStyle.getWidth(50.0),
                  height: CustomStyle.getHeight(50.0),
                  child: Container(
                      child: CircularProgressIndicator(
                        // valueColor: AlwaysStoppedAnimation<Color>(styleBaseCol1),
                      )),
                )
              ],
            )));
    pr.style(backgroundColor: Colors.transparent, elevation: 0.0);
    // pr.style(
    //     message: null,

    //     progressWidgetAlignment: Alignment.center,
    //     progressWidget: Container(
    //         color: Colors.transparent,
    //         padding: EdgeInsets.all(8.0),
    //         child: CircularProgressIndicator()),
    //     messageTextStyle: CustomStyle.baseFont());
    return pr;
  }

  static Future<void> getNotice(BuildContext context,String pageName,GlobalKey webviewKey) async {
    final controller = Get.find<App>();
    var app = await controller.getUserInfo();
    Logger logger = Logger();
    await DioService.dioClient(header: true).getNotice2(app.authorization,"Y").then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("Util getNotice() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          try {
            var list = _response.resultMap?["data"] as List;
            List<NoticeModel> itemsList = list.map((i) => NoticeModel.fromJSON(i)).toList();
            if(itemsList.isNotEmpty) {
              NoticeModel data = itemsList[0];
              var read_notice = await SP.getInt(Const.KEY_READ_NOTICE,defaultValue: 0)??0;
              if(data.boardSeq! > read_notice){
                openNotiDialog(context,pageName,webviewKey,data.boardSeq);
              }
            }
          }catch(e) {
            print("Util getNotice() Error => $e");
            Util.toast("데이터를 가져오는 중 오류가 발생하였습니다.");
          }
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("Util getNotice() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("Util getNotice() Error Default => ");
          break;
      }
    });
  }

  Future<bool> _goBack(BuildContext context,InAppWebViewController webViewController) async{
    if(await webViewController.canGoBack()){
      webViewController.goBack();
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

  static notificationDialog(BuildContext context,String pageName,GlobalKey webviewKey) async {
    final controller = Get.find<App>();
    var first_screen = await SP.getFirstScreen(context);
    if(first_screen == pageName) {
      if(!controller.isIsNoticeOpen.value) {
        controller.isIsNoticeOpen.value = true;
        getNotice(context, pageName, webviewKey);
      }
    }else{
      return;
    }
  }

  static openNotiDialog(BuildContext context,String pageName,GlobalKey webviewKey, int? seq){
    InAppWebViewController? webViewController;
    PullToRefreshController? pullToRefreshController;
    double _progress = 0;

    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.red),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));}
      },
    ))!;
    Uri myUrl = Uri.parse(SERVER_URL + URL_NOTICE_DETAIL + seq.toString());

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0))
                  ),
                  content: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(children: <Widget>[
                      _progress < 1.0
                              ? LinearProgressIndicator(value: _progress, color: Colors.red)
                              : Container(),
                          Expanded(
                            child: Stack(
                              children: [
                                InAppWebView(
                                  key: webviewKey,
                                  initialUrlRequest: URLRequest(url: myUrl),
                                  initialOptions: InAppWebViewGroupOptions(
                                    crossPlatform: InAppWebViewOptions(
                                        javaScriptCanOpenWindowsAutomatically: true,
                                        javaScriptEnabled: true,
                                        useOnDownloadStart: true,
                                        useOnLoadResource: true,
                                        useShouldOverrideUrlLoading: true,
                                        mediaPlaybackRequiresUserGesture: true,
                                        allowFileAccessFromFileURLs: true,
                                        allowUniversalAccessFromFileURLs: true,
                                        verticalScrollBarEnabled: true,
                                        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36'
                                    ),
                                    android: AndroidInAppWebViewOptions(
                                        useHybridComposition: true,
                                        allowContentAccess: true,
                                        builtInZoomControls: true,
                                        thirdPartyCookiesEnabled: true,
                                        allowFileAccess: true,
                                        supportMultipleWindows: true
                                    ),
                                    ios: IOSInAppWebViewOptions(
                                      allowsInlineMediaPlayback: true,
                                      allowsBackForwardNavigationGestures: true,
                                    ),
                                  ),
                                  pullToRefreshController: pullToRefreshController,
                                  onLoadStart: (InAppWebViewController controller, uri) {
                                    setState(() {myUrl = uri!;});
                                  },
                                  onLoadStop: (InAppWebViewController controller, uri) {
                                    setState(() {myUrl = uri!;});
                                  },
                                  onProgressChanged: (controller, progress) {
                                    if (progress == 100) {pullToRefreshController?.endRefreshing();}
                                    setState(() {_progress = progress / 100;});
                                  },
                                  androidOnPermissionRequest: (controller, origin, resources) async {
                                    return PermissionRequestResponse(
                                        resources: resources,
                                        action: PermissionRequestResponseAction.GRANT);
                                  },
                                  onWebViewCreated: (InAppWebViewController controller) {
                                    webViewController = controller;
                                  },
                                  onCreateWindow: (controller, createWindowRequest) async{
                                    showDialog(
                                      context: context, builder: (context) {
                                      return AlertDialog(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(0.0))
                                        ),
                                        content: SizedBox(
                                          width: MediaQuery.of(context).size.width,
                                          height: 400,
                                          child: InAppWebView(
                                            // Setting the windowId property is important here!
                                            windowId: createWindowRequest.windowId,
                                            initialOptions: InAppWebViewGroupOptions(
                                              android: AndroidInAppWebViewOptions(
                                                builtInZoomControls: true,
                                                thirdPartyCookiesEnabled: true,
                                              ),
                                              crossPlatform: InAppWebViewOptions(
                                                  cacheEnabled: true,
                                                  javaScriptEnabled: true,
                                                  userAgent: "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36"
                                              ),
                                              ios: IOSInAppWebViewOptions(
                                                allowsInlineMediaPlayback: true,
                                                allowsBackForwardNavigationGestures: true,
                                              ),
                                            ),
                                            onCloseWindow: (controller) async{
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        ),);
                                    },
                                    );
                                    return true;
                                  },
                                )
                              ],
                            ),
                          ),
                        ])
                  ),
                  actions: [
                              InkWell(
                                onTap: (){
                                  SP.putInt(Const.KEY_READ_NOTICE, seq!);
                                  Navigator.of(context).pop();
                                },
                                  child:SizedBox(
                                    child:Text(
                                      "  다시 열지 않음  ",
                                      style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w600),
                                    ),
                                  )
                              ),
                              InkWell(
                                onTap: (){
                                  Navigator.of(context).pop();
                                },
                                  child:SizedBox(
                                    child:Text(
                                      "  닫기  ",
                                      style: CustomStyle.CustomFont(styleFontSize16, Colors.black,font_weight: FontWeight.w600),
                                    ),
                                  )
                              )

                  ],
                );
              }
          );
        }
    );
  }

}
