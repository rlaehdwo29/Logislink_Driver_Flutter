import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/page/bridge_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logislink_driver_flutter/utils/util.dart' as app_util;

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key:key);

  @override
  _PermissionPageState createState() => _PermissionPageState();
}

Future<Map<String,dynamic>> requestPermission() async {
  if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    //print("권한 설정 완료");
    //app_util.Util.toast("권한 설정 완료");
    return Future.value(<String,String> {
      "result":"checkAll"
    });
  }else{
    // You can request multiple permissions at once.
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid) {
      AndroidDeviceInfo info  = await deviceInfo.androidInfo;
      // Android 13 버전 이상.
      if(info.version.sdkInt >= 33) {
        var phone_per = await Permission.phone.request();
        var photos_per = await Permission.photos.request();
        var location_per = await Permission.location.request();
        var activityRecognition_per = await Permission.activityRecognition.request();

        var locationPermission = await Geolocator.checkPermission();
        /*print("위치 => ${location_per}");
        print("위치 => ${await Geolocator.checkPermission()}");
        print("저장소 => ${photos_per}");
        print("폰 => ${phone_per}");
        print("신체활동 => ${activityRecognition_per}");*/

        if (photos_per == PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        } else if (phone_per == PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        } else if (location_per == PermissionStatus.permanentlyDenied || locationPermission == LocationPermission.whileInUse) {
          await openAppSettings();
        } else if (activityRecognition_per == PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        }

        if (location_per != PermissionStatus.granted) {
          return Future.value(<String,String> {
            "result":"위치"
          });
        } else if (photos_per != PermissionStatus.granted) {
          return Future.value(<String,String> {
            "result":"사진 및 동영상"
          });
        } else if (phone_per != PermissionStatus.granted) {
          return Future.value(<String,String> {
            "result":"전화"
          });
        }else if(locationPermission != LocationPermission.always) {
          return Future.value(<String,String> {
            "result":"위치 항상 허용"
          });
        } else if (activityRecognition_per != PermissionStatus.granted) {
          return Future.value(<String,String> {
            "result":"신체활동"
          });
        }
        return Future.value(<String,String> {
          "result":"checkAll"
        });

      }else {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.phone,
          Permission.storage,
          Permission.location,
          Permission.activityRecognition,
        ].request();

        /*print("Notification => ${statuses[Permission.notification]}");
        print("위치 => ${statuses[Permission.location]}");
        print("저장소 => ${statuses[Permission.storage]}");
        print("폰 => ${statuses[Permission.phone]}");
        print("신체활동 => ${statuses[Permission.activityRecognition]}");*/

        if (statuses[Permission.storage] == PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        } else if (statuses[Permission.phone] == PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        } else if (statuses[Permission.location] == PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        } else if (statuses[Permission.activityRecognition] == PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        }

        if (statuses[Permission.location] != PermissionStatus.granted) {
          return Future.value(<String,String> {
            "result":"위치"
          });
        } else if (statuses[Permission.storage] != PermissionStatus.granted) {
          return Future.value(<String,String> {
            "result":"저장소"
          });
        } else if (statuses[Permission.phone] != PermissionStatus.granted) {
          return Future.value(<String,String> {
            "result":"전화"
          });
        } else if (statuses[Permission.activityRecognition] != PermissionStatus.granted) {
          return Future.value(<String,String> {
            "result":"신체활동"
          });
        }
        return Future.value(<String,String> {
          "result":"checkAll"
        });
      }
    }else{
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.phone,
        Permission.location,
        Permission.activityRecognition,
      ].request();

      var locationPermission = await Geolocator.checkPermission();
      /* print("Notification => ${statuses[Permission.notification]}");
      print("위치 => ${statuses[Permission.location]}");
      print("위치 => ${await Geolocator.checkPermission()}");
      print("저장소 => ${statuses[Permission.photos]}");
      print("폰 => ${statuses[Permission.phone]}");
      print("신체활동 => ${statuses[Permission.activityRecognition]}");*/

      if (statuses[Permission.photos] == PermissionStatus.denied || statuses[Permission.photos] == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      } else if (statuses[Permission.phone] == PermissionStatus.denied || statuses[Permission.phone] == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      } else if (statuses[Permission.location] == PermissionStatus.denied || statuses[Permission.location] == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      } else if(locationPermission != LocationPermission.always){
        await Geolocator.openAppSettings();
      }else if (statuses[Permission.activityRecognition] == PermissionStatus.denied || statuses[Permission.activityRecognition] == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }

      if (statuses[Permission.location] != PermissionStatus.granted) {
        return Future.value(<String,String> {
          "result":"위치"
        });
      } else if (statuses[Permission.photos] != PermissionStatus.granted) {
        return Future.value(<String,String> {
          "result":"사진 및 동영상"
        });
      } else if (statuses[Permission.phone] != PermissionStatus.granted) {
        return Future.value(<String,String> {
          "result":"전화"
        });
      } else if (statuses[Permission.activityRecognition] != PermissionStatus.granted) {
        return Future.value(<String,String> {
          "result":"신체활동"
        });
      }
      return Future.value(<String,String> {
        "result":"checkAll"
      });
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
                                      text: "사용자 인증 및 식별을 위해 사용됩니다.",
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
                              Text(
                                "접근 권한 변경 방법",
                                style: CustomStyle.CustomFont(
                                    styleFontSize13, text_color_01,
                                    font_weight: FontWeight.w700),
                              ),
                              CustomStyle.sizedBoxHeight(5.0),
                              Text(
                                Platform.isAndroid ? "설정 > 애플리케이션/앱 > 로지스링크 차주용 > 권한" : "설정 > 로지스링크 차주용",
                                style: CustomStyle.CustomFont(
                                    styleFontSize11, text_color_02),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        ]),
                  ],
                ))),
        bottomNavigationBar: InkWell(
          onTap: () async {
            Map<String,dynamic>? result = await requestPermission();
            if(result["result"] == "checkAll"){
              Navigator.of(context).pop({'code': 200});
            }else{
              if(result["result"] == "위치 항상 허용") {
                app_util.Util.toast("위치 권한을 항상 허용으로 변경해주세요.");
              }else{
                app_util.Util.toast("${result["result"]} 권한을 허용해주세요.");
              }
            }
          },
          child: Container(
            height: 60.0,
            color: main_color,
            padding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            child: Text(
              "확인",
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
            ),
          ),
        )
    )
    );
  }
}