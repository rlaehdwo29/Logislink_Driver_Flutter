import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/page/bridge_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logislink_driver_flutter/utils/util.dart' as app_util;

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key:key);

  @override
  _PermissionPageState createState() => _PermissionPageState();
}

Future<bool> requestPermission() async {
  if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    //print("권한 설정 완료");
    //app_util.Util.toast("권한 설정 완료");
    return Future.value(true);
  }else{
    // You can request multiple permissions at once.
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid) {
      AndroidDeviceInfo info  = await deviceInfo.androidInfo;
      // Android 13 버전 이상.
      if(info.version.sdkInt >= 29) {
        var phone_per = await Permission.phone.request();
        var photos_per = await Permission.photos.request();
        var location_per = await Permission.location.request();
        var activityRecognition_per = await Permission.activityRecognition.request();
        var camera_per = await Permission.camera.request();

        var locationPermission = await Geolocator.checkPermission();
        /*print("위치 => ${location_per}");
        print("위치 => ${await Geolocator.checkPermission()}");
        print("저장소 => ${photos_per}");
        print("폰 => ${phone_per}");
        print("신체활동 => ${activityRecognition_per}");*/

        var requiredPermission = true;
        if (phone_per != PermissionStatus.granted) {
          requiredPermission = false;
        } else if (activityRecognition_per != PermissionStatus.granted) {
          requiredPermission = false;
        }
        return Future.value(requiredPermission);

      }else {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.phone,
          Permission.storage,
          Permission.location,
          Permission.activityRecognition,
          Permission.camera
        ].request();

        /*print("Notification => ${statuses[Permission.notification]}");
        print("위치 => ${statuses[Permission.location]}");
        print("저장소 => ${statuses[Permission.storage]}");
        print("폰 => ${statuses[Permission.phone]}");
        print("신체활동 => ${statuses[Permission.activityRecognition]}");*/
        var requiredPermission = true;
        if (statuses[Permission.phone] != PermissionStatus.granted) {
          requiredPermission = false;
        } else if (statuses[Permission.activityRecognition] != PermissionStatus.granted) {
          requiredPermission = false;
        }
        return Future.value(requiredPermission);
      }
    }else{
      final activityRecognition = FlutterActivityRecognition.instance;
      await AppTrackingTransparency.requestTrackingAuthorization();
      PermissionRequestResult recognitionResult = await activityRecognition.checkPermission();
      await activityRecognition.requestPermission();
      await Permission.photos.request();
      await Permission.location.request();
      await Permission.camera.request();

      var locationPermission = await Geolocator.checkPermission();

      var requiredPermission = true;
      if (recognitionResult != PermissionRequestResult.GRANTED) {
        requiredPermission = false;
      }
      return Future.value(requiredPermission);
    }
  }
}

class _PermissionPageState extends State<PermissionPage>{
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(    // <-  WillPopScope로 감싼다.
        onWillPop: () {
          return Future(() => false);
        },
        child: Scaffold(
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10.0),
                color: Colors.white,
                child: Column(
                  children: [
                    Text(
                      "앱 권한 안내",
                      style: CustomStyle.CustomFont(
                          styleFontSize15, text_color_01,
                          font_weight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    CustomStyle.sizedBoxHeight(10.0),
                    Text(
                      "필수 권한을 허용하지 않으면 앱 사용이 제한됩니다.",
                      style:
                      CustomStyle.CustomFont(styleFontSize12, text_color_01),
                      textAlign: TextAlign.center,
                    ),
                    CustomStyle.sizedBoxHeight(10.0),
                    CustomStyle.getDivider1(),
                    CustomStyle.sizedBoxHeight(10.0),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "필수 접근 권한",
                            style: CustomStyle.CustomFont(
                                styleFontSize13, text_color_01,
                                font_weight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          CustomStyle.sizedBoxHeight(5.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: CustomStyle.getWidth(10.0)),
                                child: const Icon(Icons.location_on,
                                    color: Colors.black, size: 24),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "위치",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize13, text_color_01,
                                        font_weight: FontWeight.w700),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: "사용자의 위치를 관제하기 위해 위치정보를 수집합니다.",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize11, text_color_02),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          CustomStyle.sizedBoxHeight(5.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: CustomStyle.getWidth(10.0)),
                                child: const Icon(Icons.call,
                                    color: Colors.black, size: 24),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "전화",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize13, text_color_01,
                                        font_weight: FontWeight.w700),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: "- 로지스링크 차주앱은 로그인 상황에서 로그인을 사용 설정하기 위해\n전화번호을 수집/전송/동기화/저장합니다.\n\n- 담당자에게 전화를 걸기 위해 해당 권한을 사용합니다.",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize11, text_color_02),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ]),
                    CustomStyle.sizedBoxHeight(10.0),
                    CustomStyle.getDivider1(),
                    CustomStyle.sizedBoxHeight(10.0),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "선택 접근 권한",
                            style: CustomStyle.CustomFont(
                                styleFontSize13, text_color_01,
                                font_weight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          CustomStyle.sizedBoxHeight(5.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: CustomStyle.getWidth(10.0)),
                                child: const Icon(Icons.image,
                                    color: Colors.black, size: 24),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "저장공간/사진",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize13, text_color_01,
                                        font_weight: FontWeight.w700),
                                  ),
                                  Text(
                                    "증빙 서류 파일 첨부",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize11, text_color_02),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            ],
                          ),
                          CustomStyle.sizedBoxHeight(5.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: CustomStyle.getWidth(10.0)),
                                child: const Icon(Icons.circle_notifications,
                                    color: Colors.black, size: 24),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "알림",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize13, text_color_01,
                                        font_weight: FontWeight.w700),
                                  ),
                                  Text(
                                    "앱 알림 권한 허용을 허가합니다.",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize11, text_color_02),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CustomStyle.sizedBoxHeight(10.0),
                          RichText(
                            text: TextSpan(
                              text: "선택적 권한은 서비스 사용 중 필요한 시점에 동의를 받고 있습니다. 동의하지 않아도 해당 기능 외 서비스 이용이 가능합니다.",
                              style: CustomStyle.CustomFont(
                                  styleFontSize13, text_color_02),
                            ),
                          ),
                          CustomStyle.sizedBoxHeight(10.0),
                          CustomStyle.getDivider1(),
                          CustomStyle.sizedBoxHeight(10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "접근 권한 변경 방법",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize13, text_color_01,
                                        font_weight: FontWeight.w700),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: light_gray24,
                                        backgroundColor: light_gray24
                                    ),
                                    onPressed: () async {
                                      AppSettings.openAppSettings();
                                    },
                                    child: Text(
                                        "권한 설정 이동",
                                      style: TextStyle(color: Colors.white,fontSize: 13.sp),
                                    ),
                                  )
                                ],
                              ),
                              CustomStyle.sizedBoxHeight(5.0),
                              Text(
                                Platform.isAndroid ? "설정 > 애플리케이션/앱 > 로지스링크 차주용 > 권한" : "설정 > 로지스링크 차주용",
                                style: CustomStyle.CustomFont(styleFontSize11, text_color_02),
                                textAlign: TextAlign.center,
                              ),
                              CustomStyle.sizedBoxHeight(5.0),
                              Text(
                                "※ \"위치\" 권한은 [권한 설정 이동] 버튼을 눌러서\n권한 > 위치 > \"항상 허용\"으로 설정 바랍니다.",
                                style: CustomStyle.CustomFont(styleFontSize16, text_color_02, font_weight: FontWeight.w800),
                                textAlign: TextAlign.start,
                              ),
                              CustomStyle.sizedBoxHeight(10.0),
                              Text(
                                "▼ 아래 [확인] 버튼을 누르시면 권한이 부여됩니다. ",
                                style: CustomStyle.CustomFont(styleFontSize16, const Color(0xffFF0033), font_weight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        ]),
                  ],
                ))),
        bottomNavigationBar: InkWell(
          onTap: () async {
            bool? result = await requestPermission();
            if(result){
              Navigator.of(context).pop({'code': 200});
            }else{
              app_util.Util.toast("${Strings.of(context)?.get("permission_failed") ?? "필요한 권한을 설정해 주세요. 앱이 종료됩니다."}");
              Future.delayed(const Duration(milliseconds: 300), () {
                exit(0);
              });
            }
          },
          child: Container(
            height: 90.0.h,
            color: const Color(0xffFF0033),
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            child: Text(
              "확인",
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize37, Colors.white, font_weight: FontWeight.w800),
            ),
          ),
        )
    )
    );
  }
}