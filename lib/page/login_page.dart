import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_main_widget.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/terms_agree_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/page/main_page.dart';
import 'package:logislink_driver_flutter/page/subPage/user_car_list_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:dio/dio.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key:key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with CommonMainWidget {

  late bool m_TermsCheck;
  late TERMS m_TermsMode;
  final controller = Get.find<App>();
  final mobileNumber = "".obs;
  final userName = "".obs;
  List<SimCard> _simCard = <SimCard>[];

  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();

    if(!Const.userDebugger) getPhoneNumber();

  }


  Future<void> getPhoneNumber() async {

    /*MobileNumber.listenPhonePermission((isPermissionGranted) async {
      if (isPermissionGranted){
        initMobileNumberState();
      } else {
        Util.snackbar(context, "핸드폰 권한을 설정해주세요.");
      }
    });
    initMobileNumberState();*/
    if(defaultTargetPlatform == TargetPlatform.android) {
      mobileNumber.value = await Util.getPhoneNum();
    }
  }

  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }

    if (!mounted) return;

    setState(() async {
      mobileNumber.value = await Util.getPhoneNum();
    });
  }

  Widget _entryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: CustomStyle.getHeight(70.0),
          child: TextField(
            style: CustomStyle.baseFont(),
            textAlign: TextAlign.start,
            keyboardType: TextInputType.number,
            onChanged: (value){
              mobileNumber.value = value;
            },
            maxLength: 50,
            decoration: InputDecoration(
                counterText: '',
                hintText: "전화번로를 입력해주세요.",
                hintStyle:CustomStyle.whiteFont(),
                contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
              ),
              disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
              )

            ),
          )
        )
      ],
    );
  }

  Widget _entryFieldNotAndroid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            height: CustomStyle.getHeight(70.0),
            child: TextField(
              style: CustomStyle.baseFont(),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.number,
              onChanged: (value){
                userName.value = value;
              },
              maxLength: 50,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: "성명을 입력해주세요.",
                  hintStyle:CustomStyle.greyDefFont(),
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  )

              ),
            )
        ),
        CustomStyle.sizedBoxHeight(20.0),
        SizedBox(
            height: CustomStyle.getHeight(70.0),
            child: TextField(
              style: CustomStyle.baseFont(),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.number,
              onChanged: (value){
                mobileNumber.value = value;
              },
              maxLength: 50,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: "전화번호를 입력해주세요.",
                  hintStyle:CustomStyle.greyDefFont(),
                  contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: line, width: CustomStyle.getWidth(0.5))
                  )

              ),
            )
        ),
      ],
    );
  }


  bool validate() {
    if (mobileNumber.replaceAll(" ","").isEmpty) {
      Util.snackbar(context,"핸드폰 번호를 입력해주세요.");
      return false;
    }
    return true;
  }

  Future<void> CheckTermsAgree() async {
    var logger = Logger();
    UserModel? user = controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).getTermsUserAgree(user?.authorization??"null",mobileNumber.value).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);

      if(_response.status == "200") {
          TermsAgreeModel user = TermsAgreeModel.fromJSON(it.response.data["data"]);
          if(user != null) {
            if(user.necessary == "N" || user.necessary == ""){
              m_TermsCheck = true;
              m_TermsMode = TERMS.UPDATE;
            }else{
              m_TermsCheck = true;
              m_TermsMode = TERMS.DONE;
            }
          }else{
            m_TermsCheck = false;
            m_TermsMode= TERMS.INSERT;
          }
          SP.putBool(Const.KEY_TERMS, true);
          userLogin();
      }else{
        openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }

    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("login_page.dart CheckTermsAgree() error : ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("login_page.dart CheckTermsAgree() error2222 :");
          break;
      }
    });
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

  void goToMain() {
    Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => const MainPage()),
                      (route) => false);
  }

  Future<void> sendDeviceInfo() async {
    Logger logger = Logger();
    UserModel? user = controller.getUserInfo();
    if(Const.userDebugger) {
      goToMain();
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
            openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
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
  
  
  Future<void> userLogin() async {
    Logger logger = Logger();

    var phone = await Util.encryption(mobileNumber.value);
    phone.replaceAll("\n", "");
    SP.putBool(Const.KEY_GUEST_MODE, false);
    await pr?.show();
    await DioService.dioClient(header: true).login(phone).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("userLogin() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
            UserModel userInfo = UserModel.fromJSON(it.response.data["data"]);
            if (userInfo != null) {
              userInfo.authorization = it.response.headers["authorization"]?[0];
              logger.i("userJson => $userInfo");
              controller.setUserInfo(userInfo);
              logger.i("User Login => ${controller.getUserInfo()?.driverId}");
              if ((controller.getUserInfo()?.vehicCnt ?? 0) > 1) {
                goToUserCar();
              } else {
                sendDeviceInfo();
              }
            } else {
              openOkBox(context, _response.message ?? "",
                  Strings.of(context)?.get("confirm") ?? "Error!!", () {
                    Navigator.of(context).pop(false);
                  });
            }
        }
      }else{
        Util.snackbar(context, "등록된 사용자가 아닙니다.");
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("login_page.dart userLogin() error : ${res?.statusCode} -> ${res?.statusMessage}");
          break;
        default:
          logger.e("login_page.dart userLogin() error222 :");
          break;
      }
    });
  }

  void goToGuestQuestion() {
    openCommonConfirmBox(
        context,
        "Guest 모드는 사용에 제한이 있습니다.\n계속 진행하시겠습니까? ",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () {
              Navigator.of(context).pop(false);
              /*Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => const MainPage()),
                      (route) => false);*/
              guestLogin();
              }
    );
  }

  Future<void> guestLogin() async {
    Logger logger = Logger();
    SP.putBool(Const.KEY_GUEST_MODE, true);
    var guest_phone = await Util.encryption("00000000000");
    //var auth = "vKqL5nyR2Z4bv3acPezJrA%3D%3D%0A";
    await pr?.show();
    await DioService.dioClient(header: true).login(guest_phone).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      if(_response.status == "200") {
        UserModel userInfo = UserModel.fromJSON(it.response.data["data"]);
        if (userInfo != null) {
          userInfo.authorization = it.response.headers["authorization"]?[0];
          logger.i("userJson => $userInfo");
          controller.setUserInfo(userInfo);
          logger.i("Guest Login => ${controller.getUserInfo()?.driverId}");
          if ((controller.getUserInfo()?.vehicCnt ?? 0) > 1) {
            goToUserCar();
          } else {
            sendDeviceInfo();
          }
        } else {
          openOkBox(context, _response.message ?? "",
              Strings.of(context)?.get("confirm") ?? "Error!!", () {
                Navigator.of(context).pop(false);
              });
        }
      }else{
        Util.snackbar(context, "등록된 사용자가 아닙니다.");
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("login_page.dart userLogin() error : ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("login_page.dart userLogin() error2222 =>");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return mainWidget(
      context,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Container(
            width:width,
            height:height,
            color:styleWhiteCol,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(50.0)),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constranints) {
                return Stack(
                  alignment: Alignment.center,
                  children:<Widget> [
                    SizedBox(
                      height: height * 0.6,
                      width: width*0.8,
                      child: SingleChildScrollView(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset("assets/image/ic_top_logo.png"),
                            CustomStyle.sizedBoxHeight(100.0),
                            Const.userDebugger? _entryField():
                            (defaultTargetPlatform != TargetPlatform.android)?_entryFieldNotAndroid():
                            Obx(() {
                            return Container(
                              alignment: Alignment.centerLeft,
                              width: width,
                              height: CustomStyle.getHeight(50.0),
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
                              decoration: BoxDecoration(
                                color: styleWhiteCol,
                                border: CustomStyle.borderAllBase()
                              ),
                              child: Text(
                                "$mobileNumber",
                                style: CustomStyle.baseFont()
                              ),
                              );
                            }),
                            Container(
                              padding: EdgeInsets.only(top: CustomStyle.getHeight(15.0)),
                              alignment: Alignment.centerLeft,
                              child:Text(
                                Strings.of(context)?.get("login_info")??"Error",
                                style: CustomStyle.CustomFont(styleFontSize11,styleBlackCol1),
                              )
                            ),
                            CustomStyle.sizedBoxHeight(50.0),
                            SizedBox(
                                width: width,
                                height: CustomStyle.getHeight(50.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: main_color,
                                        onPrimary: sub_color
                                    ),
                                    onPressed: () async {
                                      //final fcmToken = await FirebaseMessaging.instance.getToken();
                                      //print("FCM 토큰값 =>$fcmToken");
                                      //openOkBox(context, "${fcmToken}", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
                                      if(validate()) await userLogin();
                                      //print(Util.jumin_aes_Encrypt("1234566"));
                                    },
                                    child:Text(
                                      Strings.of(context)?.get("login_btn")??"Not Found",
                                      style: CustomStyle.loginTitleFont(),
                                    )
                                )
                            ),
                            CustomStyle.sizedBoxHeight(20.0),
                            InkWell(
                              onTap: () {
                                goToGuestQuestion();
                              },
                              child: Text(
                                  Strings.of(context)?.get("guest_btn")?? "Not Found",
                                  style: TextStyle(
                                      color: styleBlackCol1,
                                      fontSize: styleFontSize15,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                      decorationColor: styleBlackCol1
                                  )
                              ),
                            )
                          ],
                        )
                      )
                    )
                  ]
                );
              },
            )
          ),
        ),
      )
    );
  }
}
