import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/terms_agree_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/page/main_page.dart';
import 'package:logislink_driver_flutter/page/subPage/user_car_list_page.dart';
import 'package:logislink_driver_flutter/page/terms_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      /*try {
        final dir = await getApplicationDocumentsDirectory();
        var dirSChk = Directory('${dir.path}/sample/');
        if (await dirSChk.exists()) {
          dirSChk.deleteSync(recursive: true);
        }
        loginService = context.read<UserInfoService>();
        var userDb = LocalDbProvider();
        UserModel _user = await userDb.getUser();
        await loginService.getVersion();
        if (_user != null) {
          if (_user.loginKeep == "Y") {
            await loginService.refreshToken().then((value) {
              if (value.status == "0" || value.status == "888") {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => MainPage()),
                        (route) => false);
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => const LoginPage()),
                        (route) => false);
              }
            });
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => const LoginPage()),
                    (route) => false);
          }
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
                  (route) => false);
        }
      } catch (e) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
                (route) => false);
      }*/
      /*Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
              (route) => false);*/
      await checkLogin();

    });
  }

  Future<void> checkLogin() async {
    print("응애응애 송아지 =>${Const.userDebugger}");
    if(Const.userDebugger) {
      goToLogin();
      return;
    }

    print("응애응애 송아지2222 =>${App().getUserInfo().authorization}");
    if(App().getUserInfo().authorization != null ){
      if(App().getUserInfo().vehicCnt! >= 2) {
        goToUserCar();
      }else{
        getUserInfo();
      }
    }else{
      goToLogin();
    }

  }

  Future goToUserCar() async {
    Map<String,int> results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => UserCarListPage())
    );

    if(results != null && results.containsKey("code")){
      if(results["code"] == 200) {
        getUserInfo();
      }
    }
  }

  Future<void> getUserInfo() async {
    Logger logger = Logger();
    UserModel? nowUser = controller.getUserInfo();
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
            sendDeviceInfo();
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
          print("에러에러 => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("에러에러222 => ");
          break;
      }
    });

  }

  Future<void> sendDeviceInfo() async {
    Logger logger = Logger();
    UserModel? user = controller.getUserInfo();
    if(Const.userDebugger) {
      return;
    }
    await pr?.show();
    await DioService.dioClient(header: true).deviceUpdate(
        user?.authorization,
        Util.booleanToYn(SP.getDefaultTrueBoolean(Const.KEY_SETTING_PUSH)??false),
        Util.booleanToYn(SP.getDefaultTrueBoolean(Const.KEY_SETTING_TALK)??false),
        SP.get(Const.KEY_PUSH_ID)??"",
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
    await CheckTermsAgree();
  }

  Future<void> CheckTermsAgree() async {
    String? telNum = await Util.getPhoneNum();
    Logger logger = Logger();
    await DioService.dioClient(header: true).getTermsTelAgree(App().getUserInfo().authorization, telNum).then((it) async {
      ReturnMap response = DioService.dioResponse(it);
      logger.d("CheckTermsAgree() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["data"] != null) {
          try {
            TermsAgreeModel user = TermsAgreeModel.fromJSON(response.resultMap?["data"]);
            if (user != null) {
              if (user.necessary == "N" || user.necessary == "") {
                m_TermsCheck = true;
                m_TermsMode = TERMS.UPDATE;
                SP.putBool(Const.KEY_TERMS, false);
              } else {
                m_TermsCheck = true;
                m_TermsMode = TERMS.DONE;
                SP.putBool(Const.KEY_TERMS, true);
              }
            } else {
              m_TermsCheck = false;
              m_TermsMode = TERMS.INSERT;
              SP.putBool(Const.KEY_TERMS, false);
            }
            if (m_TermsCheck == false && m_TermsMode == TERMS.INSERT) {
              var results = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => const TermsPage())
              );

              if (results != null && results.containsKey("code")) {
                print("IntentTax CallBack!! => ${results["code"]}");
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
                print("IntentTax CallBack!! => ${results["code"]}");
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
          }catch(e) {
            print("호엥오엥옹 => $e");
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
