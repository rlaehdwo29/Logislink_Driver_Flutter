import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/config_url.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/page/subPage/webview_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../constants/const.dart';

class AppBarSettingPage extends StatefulWidget {
  _AppBarSettingPageState createState() => _AppBarSettingPageState();
}

class _AppBarSettingPageState extends State<AppBarSettingPage> {
  final controller = Get.find<App>();

  final _wakeChecked = false.obs;
  final _pushChecked = false.obs;
  final _talkChecked = false.obs;
  final _screen = "기본".obs;
  final _navi = "카카오내비".obs;
  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();
    _wakeChecked.value = SP.getBoolean(Const.KEY_SETTING_WAKE)??false;
    _pushChecked.value = SP.getBoolean(Const.KEY_SETTING_PUSH)??false;
    _talkChecked.value = SP.getBoolean(Const.KEY_SETTING_TALK)??false;
    _screen.value = SP.getFirstScreen(context);
    _navi.value = SP.getString(Const.KEY_SETTING_NAVI, "카카오내비")??"카카오내비";
  }

  Future openSelectDialog(List mList,String? type) {
    String? typeValue;
    if(type == "S") {
      typeValue = SP.getFirstScreen(context);
    }else if(type == "N") {
      typeValue = SP.getString(Const.KEY_SETTING_NAVI,"카카오내비");
    }
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder:  (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0))
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(
                            mList.length,
                                (index) {
                              var item = mList[index];
                                return InkWell(
                                  onTap: (){
                                    if(type == "S") {
                                      SP.putString(Const.KEY_SETTING_SCREEN,item);
                                      _screen.value = SP.getFirstScreen(context);
                                      Navigator.of(context).pop(false);
                                    }else if(type == "N") {
                                      SP.putString(Const.KEY_SETTING_NAVI,item);
                                      _navi.value = SP.getString(Const.KEY_SETTING_NAVI,"카카오내비")??"카카오내비";
                                      Navigator.of(context).pop(false);
                                    }
                                  },
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: CustomStyle.getHeight(15.0),
                                            horizontal: CustomStyle.getWidth(20.0)),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item,
                                                style: CustomStyle.CustomFont(
                                                    styleFontSize14, Colors.black),
                                              ),
                                              item == typeValue
                                                  ? Icon(Icons.check_rounded,
                                                      size: 28, color: sub_color)
                                                  : const SizedBox()
                                            ])));
                              }
                        )
                    ),
                  ),
                );
          }
        );
      }
    );
  }

  Future<void> sendDeviceInfo() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).deviceUpdate(
      controller.getUserInfo()?.authorization,
      Util.booleanToYn(SP.getDefaultTrueBoolean(Const.KEY_SETTING_PUSH) ?? false),
      Util.booleanToYn(SP.getDefaultTrueBoolean(Const.KEY_SETTING_TALK) ?? false),
      SP.get(Const.KEY_PUSH_ID) ?? "",
      controller.device_info["model"],
      controller.device_info["deviceOs"],
      controller.app_info["version"],
    ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("sendDeviceInfo() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {

      } else {
        Util.toast("디바이스 정보 업데이트에 실패하였습니다.");
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("appbar_setting_page.dart sendDeviceInfo() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          Util.toast("디바이스 정보 업데이트에 실패하였습니다.\n ${res?.statusMessage}");
          break;
        default:
          logger.e("appbar_setting_page.dart sendDeviceInfo() Error Default:");
          break;
      }
    });
  }

  Widget appSettingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            Strings.of(context)?.get("setting_app")??"Not Found",
            style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
          )
        ),
        // 시작 화면 설정
        InkWell(
          onTap: (){
            openSelectDialog(Const.first_screen,"S");
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: styleWhiteCol,
              border: const Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: Color(0xffACACAC)
                )
              )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_start_screen")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Row(
                  children: [
                    Text(
                      _screen.value,
                      style: CustomStyle.CustomFont(styleFontSize12, sub_color),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                      child: const Icon(Icons.keyboard_arrow_right,size: 24,color: Color(0xffACACAC))
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        // 화면 꺼짐 방지
        Container(
            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
            decoration: BoxDecoration(
                color: styleWhiteCol,
                border: const Border(
                    bottom: BorderSide(
                        width: 1.0,
                        color: Color(0xffACACAC)
                    )
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_wake")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Switch(
                    value: _wakeChecked.value,
                    onChanged: (value) {
                      setState(() {
                        _wakeChecked.value = value;
                        SP.putBool(Const.KEY_SETTING_WAKE, _wakeChecked.value);
                        SP.getBoolean(Const.KEY_SETTING_WAKE) == true ? WakelockPlus.enable() : WakelockPlus.disable();
                        sendDeviceInfo();
                      });
                    }
                )
              ],
            ),
          ),
        // 길안내 설정
        InkWell(
          onTap: (){
              openSelectDialog(Const.navi_setting,"N");
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: styleWhiteCol,
                border: const Border(
                    bottom: BorderSide(
                        width: 1.0,
                        color: Color(0xffACACAC)
                    )
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_navi")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Row(
                  children: [
                    Text(
                      _navi.value,
                      style: CustomStyle.CustomFont(styleFontSize12, sub_color),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                        child: const Icon(Icons.keyboard_arrow_right,size: 24,color: Color(0xffACACAC))
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget alramWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              Strings.of(context)?.get("setting_notice")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
            )
        ),
        // 푸시메시지 수신
        Container(
          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
          decoration: BoxDecoration(
              color: styleWhiteCol,
              border: const Border(
                  bottom: BorderSide(
                      width: 1.0,
                      color: Color(0xffACACAC)
                  )
              )
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.of(context)?.get("setting_push")??"Not Found",
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
              ),
              Switch(
                  value: _pushChecked.value,
                  onChanged: (value) {
                    setState(() {
                      _pushChecked.value = value;
                      SP.putBool(Const.KEY_SETTING_PUSH, _pushChecked.value);
                      sendDeviceInfo();
                    });
                  }
              )
            ],
          ),
        ),
        // 알림톡 수신
        Container(
          padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
          decoration: BoxDecoration(
              color: styleWhiteCol,
              border: const Border(
                  bottom: BorderSide(
                      width: 1.0,
                      color: Color(0xffACACAC)
                  )
              )
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.of(context)?.get("setting_talk")??"Not Found",
                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
              ),
              Switch(
                  value: _talkChecked.value,
                  onChanged: (value) {
                    setState(() {
                      _talkChecked.value = value;
                      SP.putBool(Const.KEY_SETTING_TALK, _talkChecked.value);
                      sendDeviceInfo();
                    });
                  }
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget termsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              Strings.of(context)?.get("setting_terms")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
            )
        ),
        // 이용약관
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_agree")??"Not Found", URL_AGREE_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: styleWhiteCol,
                border: const Border(
                    bottom: BorderSide(
                        width: 1.0,
                        color: Color(0xffACACAC)
                    )
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_agree")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: const Icon(Icons.keyboard_arrow_right,size: 24,color: Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
        // 개인정보수집 이용동의
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_privacy")??"Not Found", URL_PRIVACY_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: styleWhiteCol,
                border: const Border(
                    bottom: BorderSide(
                        width: 1.0,
                        color: Color(0xffACACAC)
                    )
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_privacy")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: const Icon(Icons.keyboard_arrow_right,size: 24,color: Color(0xffACACAC))
                )
              ],
            ),
          )
        ),
        // 개인정보 처리방침
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_privateInfo")??"Not Found", URL_PRIVATE_INFO_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: styleWhiteCol,
                border: const Border(
                    bottom: BorderSide(
                        width: 1.0,
                        color: Color(0xffACACAC)
                    )
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_privateInfo")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: const Icon(Icons.keyboard_arrow_right,size: 24,color: Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
        // 데이터보안서약
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_dataSecure")??"Not Found", URL_DATA_SECURE_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: styleWhiteCol,
                border: const Border(
                    bottom: BorderSide(
                        width: 1.0,
                        color: Color(0xffACACAC)
                    )
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_dataSecure")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: const Icon(Icons.keyboard_arrow_right,size: 24,color: Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
        // 마케팅 정보 수신 동의
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => WebViewPage(Strings.of(context)?.get("setting_marketing")??"Not Found", URL_MARKETING_TERMS)));
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: styleWhiteCol,
                border: const Border(
                    bottom: BorderSide(
                        width: 1.0,
                        color: Color(0xffACACAC)
                    )
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_marketing")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: const Icon(Icons.keyboard_arrow_right,size: 24,color: Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget etcWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              Strings.of(context)?.get("setting_etc")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
            )
        ),
        // 이용약관
        InkWell(
          onTap: () async {
            var url = Uri.parse(URL_MANUAL);
            if (await canLaunchUrl(url)) {
              launchUrl(url);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: styleWhiteCol,
                border: const Border(
                    bottom: BorderSide(
                        width: 1.0,
                        color: Color(0xffACACAC)
                    )
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context)?.get("setting_manual")??"Not Found",
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                ),
                Container(
                    padding: EdgeInsets.only(left: CustomStyle.getWidth(10.0)),
                    child: const Icon(Icons.keyboard_arrow_right,size: 24,color: Color(0xffACACAC))
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return Scaffold(
      backgroundColor: const Color(0xffececec),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
          child: AppBar(
            centerTitle: true,
            title: Text(
                Strings.of(context)?.get("drawer_menu_setting")??"Not Found",
                style: CustomStyle.appBarTitleFont(
                    styleFontSize16, styleWhiteCol)),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: styleWhiteCol,
              icon: const Icon(Icons.arrow_back),
            ),
          )),
        body: SafeArea(
          child: Obx(() {
            return SingleChildScrollView(
              child: Column(
                children: [
                  appSettingWidget(),
                  alramWidget(),
                  termsWidget(),
                  etcWidget()
                ],
              ),
            );
          }),
        ));
  }

}