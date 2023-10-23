import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/geofence_model.dart';
import 'package:logislink_driver_flutter/common/model/terms_agree_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/model/version_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/db/appdatabase.dart';
import 'package:logislink_driver_flutter/page/main_page.dart';
import 'package:logislink_driver_flutter/page/permission_page.dart';
import 'package:logislink_driver_flutter/page/subPage/user_car_list_page.dart';
import 'package:logislink_driver_flutter/page/terms_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/style_theme.dart';
import 'login_page.dart';
import 'package:dio/dio.dart';

class BridgePage extends StatefulWidget {
  const BridgePage({Key? key}) : super(key: key);

  @override
  _BridgePageState createState() => _BridgePageState();
}

class _BridgePageState extends State<BridgePage> {
  //UserInfoService loginService;

  bool m_TermsCheck = false;
  var m_TermsMode;
  final controller = Get.find<App>();
  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await checkFinishGeofence();
      bool? chkPermission = await checkPermission();
      if(chkPermission == true){
        await checkVersion();
      }else {
        await goToPermission();
      }
    });

  }

  Future goToPermission() async {
    Map<String,int> results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const PermissionPage())
    );

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await checkVersion();
      }
    }
  }

  Future<bool?> checkPermission() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid) {
      AndroidDeviceInfo info  = await deviceInfo.androidInfo;
      var phone_per = await Permission.phone.status;
      var location_per = await Permission.location.status;
      var activityRecognition_per = await Permission.activityRecognition.status;
      if (info.version.sdkInt >= 29) {
        var photos_per = await Permission.photos.status;
        var locationPermission = await Geolocator.checkPermission();
        if (location_per != PermissionStatus.granted) {
          return false;
        } else if (photos_per != PermissionStatus.granted) {
          return false;
        } else if (phone_per != PermissionStatus.granted) {
          return false;
        }else if(locationPermission != LocationPermission.always) {
          return false;
        } else if (activityRecognition_per != PermissionStatus.granted) {
          return false;
        }
        return true;
      } else {
        var storage_per = await Permission.storage.status;
        if (location_per != PermissionStatus.granted) {
          return false;
        } else if (storage_per != PermissionStatus.granted) {
          return false;
        } else if (phone_per != PermissionStatus.granted) {
          return false;
        } else if (activityRecognition_per != PermissionStatus.granted) {
          return false;
        }
        return true;
      }
    }else{
      final activityRecognition = FlutterActivityRecognition.instance;
      PermissionRequestResult recognitionResult = await activityRecognition.checkPermission();
      var activityRecognition_per = await activityRecognition.requestPermission();
      var photos_per = await Permission.photos.status;
      var location_per = await Permission.location.status;
      if (location_per != PermissionStatus.granted) {
        return false;
      } else if (photos_per != PermissionStatus.granted) {
        return false;
      } else if (activityRecognition_per != PermissionStatus.granted) {
        return false;
      }
      return true;
    }
  }

  Future<void> checkFinishGeofence() async {
    AppDataBase db = App().getRepository();
    List<GeofenceModel>? list = await db.getFinishGeofence();
    if(list != null && list.length != 0) {
      db.deleteAll(list);
    }
  }

  Future<void> checkVersion() async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).getVersion("D").then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      logger.d("checkVersion() _response -> ${_response.status} // ${_response.resultMap}");
      try {
        if (_response.status == "200") {
          var list = _response.resultMap?["data"] as List;

          if (list != null && list.isNotEmpty) {
            VersionModel? appVersion = VersionModel.fromJSON(list[0]);
            VersionModel? codeVersion = VersionModel.fromJSON(list[1]);
            String? shareVersion = await SP.get(Const.CD_VERSION);
            if (appVersion.versionCode == packageInfo.version) {
              if (shareVersion != codeVersion.versionCode) {
                await SP.putString(
                    Const.CD_VERSION, codeVersion.versionCode ?? "");
                await GetCodeTask();
              }
              await checkLogin();
            } else {
              Util.toast("새로운 앱 버전이 있습니다.");
              if (Platform.isAndroid) {
                launch(Const.ANDROID_STORE);
              } else if (Platform.isIOS) {
                //launch(Const.IOS_STORE);
              }
            }
          }
        }
      }catch(e) {
        print("checkVersion() Exection=>$e");
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("brige_page.dart checkVersion() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("brige_page.dart checkVersion() Error Default:");
          break;
      }
    });
  }

  Future<void> GetCodeTask() async {
    Logger logger = Logger();
    List<String> codeList = Const.getCodeList();
    for(String code in codeList){
      await DioService.dioClient(header: true).getCodeList(code).then((it) async {
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("GetCodeTask() _response -> ${_response.status} // ${_response.resultMap}");
        if(_response.status == "200") {
          if(_response.resultMap?["data"] != null) {
            var jsonString = jsonEncode(it.response.data);
            await SP.putCodeList(code, jsonString);
          }
        }
      }).catchError((Object obj) async {
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            logger.e("brige_page.dart GetCodeTask() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
            break;
          default:
            logger.e("brige_page.dart GetCodeTask() Error Default:");
            break;
        }
      });
    }
  }

  Future<void> checkLogin() async {
    if(Const.userDebugger) {
      await goToLogin();
      return;
    }
    var app = await App().getUserInfo();
    if(app.authorization != null ){
      if(app.vehicCnt! >= 2) {
        await goToUserCar();
      }else{
        await getUserInfo();
      }
    }else{
      await goToLogin();
    }

  }

  Future goToUserCar() async {
    Map<String,int> results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => UserCarListPage())
    );

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        await getUserInfo();
      }
    }
  }

  Future<void> getUserInfo() async {
    Logger logger = Logger();
    UserModel? nowUser = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).getUserInfo(nowUser?.authorization, nowUser?.vehicId).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("getUserInfo() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
          try {
            UserModel newUser = UserModel.fromJSON(it.response.data["data"]);
            newUser.authorization = nowUser?.authorization;
            controller.setUserInfo(newUser);
            await sendDeviceInfo();
          }catch(e) {
            print(e);
          }
        }
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("bridge_page.dart getUserInfo() Exeption=> ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("bridge_page.dart getUserInfo() Default Exeption => ");
          break;
      }
    });

  }

  Future<void> sendDeviceInfo() async {
    Logger logger = Logger();
    UserModel? user = await controller.getUserInfo();
    if(Const.userDebugger) {
      return;
    }
    await pr?.show();
    var push_id = await SP.get(Const.KEY_PUSH_ID)??"";
    var setting_push = await SP.getDefaultTrueBoolean(Const.KEY_SETTING_PUSH);
    var setting_talk = await  SP.getDefaultTrueBoolean(Const.KEY_SETTING_TALK);
    await DioService.dioClient(header: true).deviceUpdate(
        user?.authorization,
        Util.booleanToYn(setting_push),
        Util.booleanToYn(setting_talk),
        push_id,
        controller.device_info["model"],
        controller.device_info["deviceOs"],
        controller.app_info["version"]
    ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("sendDeviceInfo() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          goToMain();
        }
      }else{
        Util.toast("${_response.message}");
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("login_page.dart sendDeviceInfo() error : ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("login_page.dart sendDeviceInfo() error2222 =>");
          break;
      }
    });
  }

  void goToMain() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const MainPage()),
            (route) => false);
  }

  Future<void> goToLogin() async {
      if(defaultTargetPlatform == TargetPlatform.android){
        if (!await MobileNumber.hasPhonePermission) {
          await MobileNumber.requestPhonePermission;
        } else {
          await checkTermsAgree();
        }
      }else{
        await checkTermsAgree();
      }
  }

  Future<void> checkTermsAgree() async {

    String? telNum = "";
    if(defaultTargetPlatform == TargetPlatform.android) {
      telNum = await Util.getPhoneNum();

      if(!Const.userDebugger) {
        if (telNum.isEmpty) {
          Util.toast("단말기의 정보를 가져오는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
          Future.delayed(const Duration(milliseconds: 300), () {
            exit(0);
          });
        }
      }
    }else{
      telNum = "";
    }
    Logger logger = Logger();
    var app = await App().getUserInfo();
    await DioService.dioClient(header: true).getTermsTelAgree(app.authorization, telNum).then((it) async {
      ReturnMap response = DioService.dioResponse(it);
      logger.d("CheckTermsAgree() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["result"] == true) {
          try {
            if (response.resultMap?["data"] != null) {
              TermsAgreeModel user = TermsAgreeModel.fromJSON(response.resultMap?["data"]);
              if (user.necessary == "N" || user.necessary == "") {
                m_TermsCheck = true;
                m_TermsMode = TERMS.UPDATE;
                await SP.putBool(Const.KEY_TERMS, false);
              } else {
                m_TermsCheck = true;
                m_TermsMode = TERMS.DONE;
                await SP.putBool(Const.KEY_TERMS, true);
              }
            } else {
              m_TermsCheck = false;
              m_TermsMode = TERMS.INSERT;
              await SP.putBool(Const.KEY_TERMS, false);
            }
            if (m_TermsCheck == false && m_TermsMode == TERMS.INSERT) {
              var results = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => const TermsPage())
              );

              if (results != null && results.containsKey("code")) {
                if (results["code"] == 200) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => const LoginPage()),
                          (route) => false);
                }
              }
            } else if (m_TermsCheck == false && m_TermsMode == TERMS.UPDATE) {
              var results = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => const TermsPage())
              );

              if (results != null && results.containsKey("code")) {
                if (results["code"] == 200) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => const LoginPage()),
                          (route) => false);
                }
              }
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => const LoginPage()),
                      (route) => false);
            }
            /*await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const TermsPage()));*/
          }catch(e) {
            print("CheckTermsAgree Exepction => $e");
          }
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("CheckTermsAgree() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("CheckTermsAgree() Error Default => ");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return Container(
      color: styleWhiteCol,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        backgroundColor: styleGreyCol1,
      ),
    );
  }
}
