import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/code_model.dart';
import 'package:logislink_driver_flutter/common/model/juso_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/page/subPage/addr_search_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:logislink_driver_flutter/widget/show_bank_check_widget.dart';
import 'package:logislink_driver_flutter/widget/show_select_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class AppBarMyPage extends StatefulWidget {
  final void Function(bool?)? onCallback;
  String? code;


  AppBarMyPage({Key? key,this.code,this.onCallback}):super(key: key);

  _AppBarMyPageState createState() => _AppBarMyPageState();
}

class _AppBarMyPageState extends State<AppBarMyPage> {
  final controller = Get.find<App>();
  final editMode = false.obs;
  final mData = UserModel().obs;
  final tempData = UserModel().obs;

  static const String EDIT_BIZ = "edit_biz";
  final bizFocus = false.obs;

  ProgressDialog? pr;

  TextEditingController cargoBoxController = TextEditingController();
  TextEditingController bizNumController = TextEditingController();
  TextEditingController subBizNumController = TextEditingController();
  TextEditingController bizNameController = TextEditingController();
  TextEditingController ceoController = TextEditingController();
  TextEditingController socNoController = TextEditingController();
  TextEditingController bizAddrDetailController = TextEditingController();
  TextEditingController bizCondController = TextEditingController();
  TextEditingController bizKindController = TextEditingController();
  TextEditingController driverEmailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    cargoBoxController.dispose();
    bizNumController.dispose();
    subBizNumController.dispose();
    bizNameController.dispose();
    ceoController.dispose();
    socNoController.dispose();
    bizAddrDetailController.dispose();
    bizCondController.dispose();
    bizKindController.dispose();
    driverEmailController.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      mData.value = await App().getUserInfo();
      tempData.value =  UserModel(
          authorization:mData.value.authorization,
          driverId:mData.value.driverId,
          vehicId:mData.value.vehicId,
          driverName:mData.value.driverName,
          carNum:mData.value.carNum,
          mobile:mData.value.mobile,
          telnum:mData.value.telnum,
          pushYn:mData.value.pushYn,
          talkYn:mData.value.talkYn,
          bankCode:mData.value.bankCode,
          bankCnnm:mData.value.bankCnnm,
          bankAccount:mData.value.bankAccount,
          carTypeCode:mData.value.carTypeCode,
          carTypeName:mData.value.carTypeName,
          carTonCode:mData.value.carTonCode,
          carTonName:mData.value.carTonName,
          bizName:mData.value.bizName,
          bizNum:mData.value.bizNum,
          ceo:mData.value.ceo,
          socNo: mData.value.socNo,
          bizPost:mData.value.bizPost,
          bizAddr:mData.value.bizAddr,
          bizAddrDetail:mData.value.bizAddrDetail,
          subBizNum:mData.value.subBizNum,
          bizKind:mData.value.bizKind,
          bizCond:mData.value.bizCond,
          driverEmail:mData.value.driverEmail,
          vehicCnt:mData.value.vehicCnt,
          dangerGoodsYn:mData.value.dangerGoodsYn,
          chemicalsYn:mData.value.chemicalsYn,
          foreignLicenseYn:mData.value.foreignLicenseYn,
          forkliftYn:mData.value.forkliftYn,
          cargoBox:mData.value.cargoBox,
          bankchkDate:mData.value.bankchkDate);

      cargoBoxController.text = tempData.value.cargoBox??"";
      bizNumController.text = makeBizNum(tempData.value.bizNum??"")??"";
      subBizNumController.text = tempData.value.subBizNum??"";
      bizNameController.text = tempData.value.bizName??"";
      ceoController.text = tempData.value.ceo??"";
      socNoController.text = Util.getSocNumStrToStr(tempData.value.socNo??"")??"";
      bizAddrDetailController.text = tempData.value.bizAddrDetail??"";
      bizCondController.text = tempData.value.bizCond??"";
      bizKindController.text = tempData.value.bizKind??"";
      driverEmailController.text = tempData.value.driverEmail??"";
    });

    if(widget.code != null) {
      if(widget.code == EDIT_BIZ) {
        editMode.value = true;
        bizFocus.value = true;
      }
    }

  }

  void selectItem(CodeModel? codeModel,{codeType = "",value = 0}) {
    if(codeType != ""){
      switch(codeType) {
        case 'CAR_TYPE_CD':
          tempData.value.carTypeName = codeModel?.codeName??"";
          tempData.value.carTypeCode = codeModel?.code;
          break;
        case 'CAR_TON_CD':
          tempData.value?.carTonName = codeModel?.codeName??"";
          tempData.value.carTonCode = codeModel?.code;
          break;
        case 'YN_SEL' :
          if(value != 0){
            if(value == 1) tempData.value?.dangerGoodsYn = codeModel?.code??"";
            if(value == 2) tempData.value?.chemicalsYn = codeModel?.code??"";
            if(value == 3) tempData.value?.foreignLicenseYn = codeModel?.code??"";
            if(value == 4) tempData.value?.forkliftYn = codeModel?.code??"";
          }
          break;
      }
    }
    setState(() {});
  }

  void selectAddrCallback(String? zipNo, String? addr) {
    if(addr != null || zipNo != null) {
      tempData.value?.bizAddr = addr;
      tempData.value?.bizPost = zipNo;
      setState(() {});
    }
  }

  Future<void> edit() async {
    var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
    if(guest) {
      showGuestDialog();
      return;
    }
    if(!editMode.value) {
        editMode.value == true;
        if(tempData.value.bizCond?.isEmpty == true) {
          tempData.value.bizCond = "운수업";
        }
        if(tempData.value.bizKind?.isEmpty == true) {
          tempData.value.bizKind = "화물운송";
        }
        setState(() {});
    }else{
      if(validation()){
        showUpdate();
      }
    }
  }

  void showUpdate() {
    openCommonConfirmBox(
        context,
        "정보를 수정하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () async {
          Navigator.of(context).pop(false);
          await updateUser();
        }
    );
  }

  Future<bool?> showCanceled() async {
    await openCommonConfirmBox(
        context,
        "정보를 취소하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {
          Navigator.of(context).pop(false);
          return false;
          },
            () async {
              tempData.value = await controller.getUserInfo();
              editMode.value = false;
          setState((){
            cargoBoxController.text = tempData.value.cargoBox??"";
            bizNumController.text = makeBizNum(tempData.value.bizNum??"")??"";
            subBizNumController.text = tempData.value.subBizNum??"";
            bizNameController.text = tempData.value.bizName??"";
            ceoController.text = tempData.value.ceo??"";
            socNoController.text = Util.getSocNumStrToStr(tempData.value.socNo??"")??"";
            bizAddrDetailController.text = tempData.value.bizAddrDetail??"";
            bizCondController.text = tempData.value.bizCond??"";
            bizKindController.text = tempData.value.bizKind??"";
            driverEmailController.text = tempData.value.driverEmail??"";
          });
          Util.toast("정보수정이 취소되었습니다.");
          Navigator.of(context).pop(false);
          return true;
        }
    );
  }

  void createDummyEmail() {
    driverEmailController.text = "${tempData.value.mobile}@logis-link.co.kr";
    tempData.value.driverEmail = "${tempData.value.mobile}@logis-link.co.kr";
    setState(() {});
  }

  Future<void> updateUser() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).updateUser(tempData.value?.authorization, tempData.value?.vehicId,tempData.value?.bizName,tempData.value?.bizNum,tempData.value?.subBizNum,tempData.value?.ceo,tempData.value?.bizPost,tempData.value?.bizAddr,tempData.value?.bizAddrDetail,tempData.value.socNo,
        tempData.value?.bizCond, tempData.value?.bizKind, tempData.value?.driverEmail, tempData.value?.carTypeCode, tempData.value?.carTonCode, tempData.value?.cargoBox,tempData.value?.dangerGoodsYn, tempData.value?.chemicalsYn,tempData.value?.foreignLicenseYn, tempData.value?.forkliftYn).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("updateUser() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          editMode.value = false;
          await controller.setUserInfo(tempData.value);
          Util.toast("정보가 수정되었습니다.");
        }else{
          Util.toast(_response.resultMap?["msg"]);
        }
      }else{
        Util.toast(_response.message);
      }
      setState(() {});
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("appbar_mypage.dart updateUser() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("appbar_mypage.dart updateUser() Error Default:");
          break;
      }
    });
  }

  void showGuestDialog(){
    openOkBox(context, Strings.of(context)?.get("Guest_Permission_Mode")??"Error", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
  }

  bool validation() {
    if(tempData.value.carTonCode == null || tempData.value.carTypeCode?.isEmpty == true) {
      Util.toast("차종을 입력해 주세요.");
      return false;
    }
    if(tempData.value.carTonCode == null || tempData.value.carTonCode?.isEmpty == true) {
      Util.toast("톤수를 입력해 주세요.");
      return false;
    }
    return true;
  }

  String? ynToPossible(String? yn) {
    return Util.ynToPossible(yn);
  }

  String? makePhoneNumber(String? phone) {
    if (phone == null || phone?.isEmpty == true) {
      return phone;
    } else {
      return Util.makePhoneNumber(phone);
    }
  }

  String? makeBizNum(String num){
    if(num == null || num.isEmpty) {
      return num;
    }else{
      return Util.makeBizNum(num);
    }
  }

  String getBankName(String? code) {
    return SP.getCodeName(Const.BANK_CD, code??"");
  }

  void _callback(String? bankCd, String? acctNm, String? acctNo) async {
      UserModel? user = await controller.getUserInfo();
      user?.bankCode = bankCd;
      user?.bankCnnm = acctNm;
      user?.bankAccount = acctNo;
      controller.setUserInfo(user!);
      mData.value = await App().getUserInfo();
  }

  Widget accountInfo(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: CustomStyle.getHeight(20.0)),
        child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(bottom: CustomStyle.getHeight(10.0)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Strings.of(context)?.get("tax_sub_title_02") ?? "Not Found",
                        textAlign: TextAlign.center,
                        style:
                        CustomStyle.CustomFont(styleFontSize16, text_color_01),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: sub_color,
                            onPrimary: main_color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onPressed: () async {
                            var app = await App().getUserInfo();
                            ShowBankCheckWidget(context: context,callback: _callback).showBankCheckDialog(app);
                          },
                          child: Text(
                            Strings.of(context)?.get("tax_bank_edit") ??
                                "Not Fount",
                            style: CustomStyle.CustomFont(
                                styleFontSize10, styleWhiteCol),
                          ))
                    ],
                  )),
              Container(
                decoration: CustomStyle.customBoxDeco(styleWhiteCol,radius: 0,border_color: line),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: CustomStyle.getWidth(0.5),color: line
                              )
                          )
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            width: CustomStyle.getWidth(0.5),color: line
                                        )
                                    )
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  Strings.of(context)?.get("bank_name")??"Not Found",
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
                                  getBankName(mData.value.bankCode),
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: CustomStyle.getWidth(0.5),color: line
                              )
                          )
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            width: CustomStyle.getWidth(0.5),color: line
                                        )
                                    )
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  Strings.of(context)?.get("bank_account")??"Not Found",
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
                                  "${mData.value.bankAccount}",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: CustomStyle.getWidth(0.5),color: line
                              )
                          )
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            width: CustomStyle.getWidth(0.5),color: line
                                        )
                                    )
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  Strings.of(context)?.get("bank_cnnm")??"Not Found",
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
                                  "${mData.value.bankCnnm}",
                                  style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ]));
  }

  Widget businessInfoWidget(BuildContext context) {

    return Column(children: [
      Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
          child: Text(
            "사업자정보",
            style: CustomStyle.CustomFont(styleFontSize15, text_color_01),
          )),
      Container(
        decoration: CustomStyle.customBoxDeco(styleWhiteCol,
            border_color: line, radius: 0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom:
                    BorderSide(color: line, width: CustomStyle.getWidth(0.5)),
              )),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            Strings.of(context)?.get("biz_num") ?? "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5)),
                                  left: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5))
                              )
                          ),
                          child: TextField(
                        maxLines: 1,
                        maxLength: 12,
                        controller: bizNumController,
                        style: CustomStyle.CustomFont(styleFontSize10, text_color_01),
                        autofocus: bizFocus.value,
                        enabled: editMode.value,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        keyboardType: TextInputType.number,
                        onChanged: (bizNumText) {
                            if(bizNumText.isNotEmpty) {
                              bizNumController.text = makeBizNum(bizNumText.replaceAll("-", ""))!;
                              bizNumController.selection = TextSelection.fromPosition(TextPosition(offset: bizNumController.text.length));
                              tempData.value.bizNum = bizNumText.replaceAll("-", "");
                            }else{
                              tempData.value.bizNum = "";
                            }
                        },
                        textAlignVertical: TextAlignVertical.center,
                        decoration:  bizNumController.text.isNotEmpty && editMode.value ? InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          suffixIcon: IconButton(
                            onPressed:(){
                              bizNumController.clear();
                              tempData.value.bizNum = "";
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear,size: 12),
                          ),
                        ) : const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      )
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            Strings.of(context)?.get("sub_biz_num") ??
                                "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5)))),
                          child: TextField(
                            maxLines: 1,
                            maxLength: 12,
                            controller: subBizNumController,
                            style: CustomStyle.CustomFont(styleFontSize10, text_color_01),
                            autofocus: false,
                            enabled: editMode.value,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            keyboardType: TextInputType.number,
                            onChanged: (subBizNumText) {
                                if(subBizNumText.isNotEmpty) {
                                  subBizNumController.selection = TextSelection.fromPosition(TextPosition(offset: subBizNumController.text.length));
                                  tempData.value.subBizNum = subBizNumText;
                                }else{
                                  tempData.value.subBizNum = "";
                                }
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: subBizNumController.text.isNotEmpty && editMode.value ? InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              suffixIcon: IconButton(
                                onPressed:subBizNumController.clear,
                                icon: const Icon(Icons.clear,size: 12),
                              ),
                            ) : const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ))),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom:
                    BorderSide(color: line, width: CustomStyle.getWidth(0.5)),
              )),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            Strings.of(context)?.get("biz_name") ?? "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 4,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5)))),
                          child: TextField(
                        maxLines: 1,
                        controller: bizNameController,
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        autofocus: false,
                        enabled: editMode.value,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        keyboardType: TextInputType.text,
                        onChanged: (BizNameText) {
                            if(BizNameText.isNotEmpty) {
                              bizNameController.selection = TextSelection.fromPosition(TextPosition(offset: bizNameController.text.length));
                              tempData.value.bizName = BizNameText;
                            }else{
                              tempData.value.bizName = "";
                            }
                        },
                        textAlignVertical: TextAlignVertical.center,
                        decoration: bizNameController.text.isNotEmpty && editMode.value ? InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          suffixIcon: IconButton(
                            onPressed: () {
                              bizNameController.clear();
                              tempData.value.bizName = "";
                              },
                            icon: const Icon(Icons.clear,size: 12),
                          ),
                        ) : const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      )))
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom:
                    BorderSide(color: line, width: CustomStyle.getWidth(0.5)),
              )),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            Strings.of(context)?.get("ceo") ?? "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 4,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5)))),
                          child: TextField(
                            maxLines: 1,
                            maxLength: 12,
                            controller: ceoController,
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                            autofocus: false,
                            enabled: editMode.value,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            keyboardType: TextInputType.text,
                            onChanged: (ceoText) {
                                if(ceoText.isNotEmpty) {
                                  ceoController.selection = TextSelection.fromPosition(TextPosition(offset: ceoController.text.length));
                                  tempData.value.ceo = ceoText;
                                }else{
                                  tempData.value.ceo = "";
                                }
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: ceoController.text.isNotEmpty && editMode.value ? InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  ceoController.clear();
                                  tempData.value.ceo = "";
                                  setState(() {});
                                  },
                                icon: const Icon(Icons.clear,size: 12),
                              ),
                            ) : const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          )))
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                    bottom:
                    BorderSide(color: line, width: CustomStyle.getWidth(0.5)),
                  )),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            Strings.of(context)?.get("socNo") ?? "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 4,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5)))),
                          child: TextField(
                            maxLines: 1,
                            maxLength: 12,
                            controller: socNoController,
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                            autofocus: false,
                            enabled: editMode.value,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            keyboardType: TextInputType.number,
                            onChanged: (socNoText) {
                              if(socNoText.isNotEmpty) {
                                String valueTxt = socNoText.replaceAll(".","");
                                if(valueTxt.length > 6) {
                                  String subText = socNoText.replaceAll(".", "").substring(0,6);
                                  socNoController.text = Util.getSocNumStrToStr(subText)!;
                                  Util.toast("생년월일은 6자리를 넘길 수 없습니다.");
                                }else {
                                  socNoController.text = Util.getSocNumStrToStr(socNoText.replaceAll(".", ""))!;
                                  socNoController.selection = TextSelection.fromPosition(TextPosition(offset: socNoController.text.length));
                                  tempData.value.socNo = socNoText.replaceAll(".", "");
                                }
                              }else{
                                tempData.value.socNo = "";
                              }
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: socNoController.text.isNotEmpty && editMode.value ? InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  socNoController.clear();
                                  tempData.value.socNo = "";
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear,size: 12),
                              ),
                            ) : const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          )))
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom:
                    BorderSide(color: line, width: CustomStyle.getWidth(0.5)),
              )),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              border: Border(
                                    right: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5)))),
                          child: Text(
                            Strings.of(context)?.get("addr") ?? "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: (){
                          if(editMode.value) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    AddrSearchPage(
                                        callback: selectAddrCallback))
                            );
                          }
                        },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children : [
                                Expanded(
                                  flex: 7,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Text(
                                    "${tempData.value.bizAddr}",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12, text_color_01),
                                  )),
                                ),
                                Expanded(
                                  flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(right: CustomStyle.getWidth(10.0)),
                                        child: Icon(Icons.search,size: 32,color: text_color_02)
                                    )
                                )
                        ])
                      )
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom:
                    BorderSide(color: line, width: CustomStyle.getWidth(0.5)),
              )),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            Strings.of(context)?.get("addr_detail") ??
                                "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 4,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5)))),
                          child: TextField(
                        maxLines: 1,
                        controller: bizAddrDetailController,
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        autofocus: false,
                        enabled: editMode.value,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        keyboardType: TextInputType.text,
                        onChanged: (bizAddrDetailText) {
                            if(bizAddrDetailText.isNotEmpty) {
                              bizAddrDetailController.selection = TextSelection.fromPosition(TextPosition(offset: bizAddrDetailController.text.length));
                              tempData.value.bizAddrDetail = bizAddrDetailText;
                            }else{
                              tempData.value.bizAddrDetail = "";
                            }
                        },
                        textAlignVertical: TextAlignVertical.center,
                        decoration: bizAddrDetailController.text.isNotEmpty && editMode.value ? InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          suffixIcon: IconButton(
                            onPressed:() {
                              bizAddrDetailController.clear();
                              tempData.value.bizAddrDetail = "";
                              setState(() {});
                              },
                            icon: const Icon(Icons.clear,size: 12),
                          ),
                        ) : const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      )))
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom:
                    BorderSide(color: line, width: CustomStyle.getWidth(0.5)),
              )),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            Strings.of(context)?.get("biz_cond") ?? "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 3,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5)),
                                left: BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(0.5)),
                              )),
                          child: TextField(
                            maxLines: 1,
                            controller: bizCondController,
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                            autofocus: false,
                            enabled: editMode.value,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            keyboardType: TextInputType.text,
                            onChanged: (bizCondText) {
                                if(bizCondText.isNotEmpty) {
                                  bizCondController.selection = TextSelection.fromPosition(TextPosition(offset: bizCondController.text.length));
                                  tempData.value.bizCond = bizCondText;
                                }else{
                                  tempData.value.bizCond = "";
                                }
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: bizCondController.text.isNotEmpty && editMode.value ? InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  bizCondController.clear();
                                  tempData.value.bizCond = "";
                                  setState(() {});
                                  },
                                icon: const Icon(Icons.clear,size: 12),
                              ),
                            ) : const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ))),
                  Expanded(
                      flex: 2,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            Strings.of(context)?.get("biz_kind") ?? "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 3,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: line,
                                      width: CustomStyle.getWidth(0.5)))),
                          child: TextField(
                            maxLines: 1,
                            controller: bizKindController,
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                            autofocus: false,
                            enabled: editMode.value,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            keyboardType: TextInputType.text,
                            onChanged: (bizKindText) {
                                if(bizKindText.isNotEmpty) {
                                  bizKindController.selection = TextSelection.fromPosition(TextPosition(offset: bizKindController.text.length));
                                  tempData.value.bizKind = bizKindText;
                                }else{
                                  tempData.value.bizKind = "";
                                }
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration:bizKindController.text.isNotEmpty && editMode.value ? InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              suffixIcon: IconButton(
                                onPressed:() {
                                  bizKindController.clear();
                                  tempData.value.bizKind = "";
                                  setState(() {});
                                  },
                                icon: const Icon(Icons.clear,size: 12),
                              ),
                            ) : const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ))),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom:
                    BorderSide(color: line, width: CustomStyle.getWidth(0.5)),
              )),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            Strings.of(context)?.get("driver_email") ??
                                "Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                          ))),
                  Expanded(
                      flex: 4,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(0.5)))),
                          child: TextField(
                            maxLines: 1,
                            controller: driverEmailController,
                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                            autofocus: false,
                            enabled: editMode.value,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            keyboardType: TextInputType.text,
                            onChanged: (driveEmailText) {
                                if(driveEmailText.isNotEmpty) {
                                  driverEmailController.selection = TextSelection.fromPosition(TextPosition(offset: driverEmailController.text.length));
                                  tempData.value.driverEmail = driveEmailText;
                                }else{
                                  tempData.value.driverEmail = "";
                                }
                                setState(() {});
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: editMode.value ?
                            driverEmailController.text?.isNotEmpty == true? InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              suffixIcon: IconButton(
                                onPressed: (){
                                  driverEmailController.clear();
                                  tempData.value.driverEmail = "";
                                  setState(() {});
                                  },
                                icon: const Icon(Icons.clear,size: 12),
                              ),
                            ) : InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              suffix: InkWell(
                                onTap: (){
                                  createDummyEmail();
                                },
                                child: Container(
                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                                decoration: CustomStyle.customBoxDeco(text_color_02,radius: 5),
                                child:  Text(
                                  "없음",
                                  style: CustomStyle.CustomFont(styleFontSize10, styleWhiteCol),
                                )
                              )),
                            ) : const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ),
                      ))
                ],
              ),
            ),
          ],
        )
      )
    ]);
  }

  Widget licenseWidget() {
    return Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
            child: Text(
              "자격면허",
              style: CustomStyle.CustomFont(styleFontSize15, text_color_01),
            )
        ),
        Container(
            decoration: CustomStyle.customBoxDeco(styleWhiteCol,radius: 0,border_color: line),
            child: Column(
              children: [
                // 1번째줄
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: CustomStyle.getWidth(0.5),
                              color: line
                          )
                      )
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: CustomStyle.getWidth(0.5),
                                          color: line
                                      )
                                  )
                              ),
                              child: Text("${Strings.of(context)?.get("danger_goods")}",textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                          )
                      ),
                      Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () {
                              if(editMode.value) ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("danger_goods")??"", codeType: Const.YN_SEL, value: 1, callback: selectItem).showDialog();
                            },
                              child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("${ynToPossible(tempData.value?.dangerGoodsYn)}",style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                              )
                           )
                      )
                    ],
                  ),
                ),
                // 2번째줄
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: CustomStyle.getWidth(0.5),
                              color: line
                          )
                      )
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: CustomStyle.getWidth(0.5),
                                          color: line
                                      )
                                  )
                              ),
                              child: Text("${Strings.of(context)?.get("chemicals")}",textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                          )
                      ),
                      Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: (){
                              if(editMode.value) ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("chemicals")??"", codeType: Const.YN_SEL, value: 2, callback: selectItem).showDialog();
                            },
                              child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("${ynToPossible(tempData.value.chemicalsYn)}",style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                              )
                           )
                      )
                    ],
                  ),
                ),
                // 3번째줄
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: CustomStyle.getWidth(0.5),
                              color: line
                          )
                      )
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: CustomStyle.getWidth(0.5),
                                          color: line
                                      )
                                  )
                              ),
                              child: Text("${Strings.of(context)?.get("foreign_license")}",textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                          )
                      ),
                      Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: (){
                              if(editMode.value) ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("foreign_license")??"", codeType: Const.YN_SEL, value: 3, callback: selectItem).showDialog();
                            },
                              child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("${ynToPossible(tempData.value.foreignLicenseYn)}",style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                              )
                          )
                      )
                    ],
                  ),
                ),
                // 4번째줄
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: CustomStyle.getWidth(0.5),
                              color: line
                          )
                      )
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: CustomStyle.getWidth(0.5),
                                          color: line
                                      )
                                  )
                              ),
                              child: Text("${Strings.of(context)?.get("forklift")}",textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                          )
                      ),
                      Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: (){
                              if(editMode.value) ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("forklift")??"", codeType: Const.YN_SEL, value: 4, callback: selectItem).showDialog();
                            },
                              child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("${ynToPossible(tempData.value.forkliftYn)}",style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                              )
                          )
                      )
                    ],
                  ),
                )
              ],
            )
        )
      ],
    );
  }

  Widget baseInfoWidget() {

    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
          child: Text(
            "기본정보",
            style: CustomStyle.CustomFont(styleFontSize15, text_color_01),
          )
        ),
        Container(
          decoration: CustomStyle.customBoxDeco(styleWhiteCol,radius: 0,border_color: line),
          child: Column(
            children: [
              // 1번째줄
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: CustomStyle.getWidth(0.5),
                      color: line
                    )
                  )
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              width: CustomStyle.getWidth(0.5),
                              color: line
                            )
                          )
                        ),
                        child: Text("${Strings.of(context)?.get("car_num")}",textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                      )
                    ),
                    Expanded(
                        flex: 3,
                        child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(tempData.value?.carNum??"",style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                        )
                    )
                  ],
                ),
              ),
              // 2번째줄
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: CustomStyle.getWidth(0.5),
                            color: line
                        )
                    )
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        width: CustomStyle.getWidth(0.5),
                                        color: line
                                    )
                                )
                            ),
                            child: Text("${Strings.of(context)?.get("car_type")}",textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                        )
                    ),
                    Expanded(
                        flex: 4,
                        child: InkWell(
                          onTap: (){
                            if(editMode.value) ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("car_type")??"", codeType: Const.CAR_TYPE_CD, callback: selectItem).showDialog();
                          },
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(tempData.value?.carTypeName??"",style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                          )
                        )
                    ),
                    Expanded(
                        flex: 2,
                        child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        width: CustomStyle.getWidth(0.5),
                                        color: line
                                    ),
                                  left: BorderSide(
                                      width: CustomStyle.getWidth(0.5),
                                      color: line
                                  )
                                )
                            ),
                            child: Text("${Strings.of(context)?.get("car_ton")}",textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                        )
                    ),
                    Expanded(
                        flex: 4,
                        child: InkWell(
                          onTap: (){
                            if(editMode.value) ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("car_ton")??"", codeType: Const.CAR_TON_CD, callback: selectItem).showDialog();
                          },
                            child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(tempData.value?.carTonName??"",style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                          )
                        )
                    )
                  ],
                ),
              ),
              // 3번째줄
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: CustomStyle.getWidth(0.5),
                            color: line
                        )
                    )
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(Strings.of(context)?.get("car_width")??"Not Found",textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                        )
                    ),
                    Expanded(
                        flex: 5,
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                            decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        width: CustomStyle.getWidth(0.5),
                                        color: line
                                    )
                                )
                            ),
                            child: TextField(
                              maxLines: 1,
                              maxLength: 12,
                              controller: cargoBoxController,
                              style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                              autofocus: false,
                              enabled: editMode.value,
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              keyboardType: TextInputType.number,
                              onChanged: (cargoBoxText) {
                                  if(cargoBoxText.isNotEmpty) {
                                    cargoBoxController.selection = TextSelection.fromPosition(TextPosition(offset: cargoBoxController.text.length));
                                    tempData.value.cargoBox = makeBizNum(cargoBoxText)!;
                                  }else{
                                    tempData.value.cargoBox = "";
                                  }
                              },
                              textAlignVertical: TextAlignVertical.center,
                              decoration:  cargoBoxController.text.isNotEmpty && editMode.value ? InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                suffixIcon: IconButton(
                                  onPressed: cargoBoxController.clear,
                                  icon: const Icon(Icons.clear,size: 12),
                                ),
                              ) : const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            )
                        )
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child:Text("m",style: CustomStyle.CustomFont(styleFontSize12, text_color_01))
                    )
                  ],
                ),
              )
            ],
          )
        )
      ],
    );
  }

  Widget topWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.25,
        padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0),vertical: CustomStyle.getHeight(20.0)),
        color: main_color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
                children: [
                  Text(
                    "${mData.value.driverName}",
                    style: CustomStyle.CustomFont(styleFontSize22, styleWhiteCol,font_weight: FontWeight.w900),
                  ),
                  Text(" 차주님", style: CustomStyle.CustomFont(styleFontSize18, styleWhiteCol))
                ]),
            Container(
                padding: EdgeInsets.only(top: CustomStyle.getHeight(10.0)),
                child: Row(
                  children: [
                    Icon(Icons.call,size: 24, color: styleWhiteCol),
                    Text(
                      "  ${makePhoneNumber(mData.value.mobile)}",
                      style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                    )
                  ],
                )
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);

    return WillPopScope(
        onWillPop: () async {
          var app = await controller.getUserInfo();
          if(app != tempData.value) {
            var result = await showCanceled();
            if (result == true) {
              return true;
            } else {
              return false;
            }
          }
          if(widget.onCallback != null) {
            widget.onCallback!(true);
          }
          return true;
        },
        child: Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(60.0)),
          child: Obx((){
            return AppBar(
                title: Text(
                    "내정보 수정",
                    style: CustomStyle.appBarTitleFont(styleFontSize18,styleWhiteCol)
                ),
                leading: IconButton(
                  onPressed: () async {
                    var app = await controller.getUserInfo();
                if(app != tempData.value) {
                  await showCanceled();
                }else{
                  if(widget.onCallback != null) {
                    widget.onCallback!(true);
                  }
                  Navigator.of(context).pop();
                }

                  },
                  color: styleWhiteCol,
                  icon: Icon(Icons.keyboard_arrow_left,size: 32.w,color: styleWhiteCol),
                ),
                actions: [
                IconButton(
                onPressed: () async {
                  var guest = await SP.getBoolean(Const.KEY_GUEST_MODE);
                  if(guest) {
                    showGuestDialog();
                    return;
                  }
              if(editMode.value == true) {
                var app = await controller.getUserInfo();
                if(app != tempData.value) {
                  if(tempData.value.socNo?.length != 6) return Util.toast("생년월일을 6자리로 설정해주세요.");
                  await edit();
                }else{
                  editMode.value = !editMode.value;
                }
              } else {
                  editMode.value = !editMode.value;
              }
            },
            icon: editMode.value == false ? Icon(Icons.edit,size: 24,color: styleWhiteCol) : Icon(Icons.check,size: 24,color: styleWhiteCol)
              )
            ],
          );
        })
      ),
      body: Obx((){
        return SafeArea(
          child: SingleChildScrollView(
              child: Column(
                children: [
                  topWidget(),
                  Container(
                    padding: EdgeInsets.fromLTRB(CustomStyle.getWidth(10.0), CustomStyle.getHeight(10.0), CustomStyle.getWidth(10.0),  CustomStyle.getHeight(50.0)),
                    color: styleDividerGrey,
                    child: Column(
                      children: [
                        baseInfoWidget(),
                        licenseWidget(),
                        businessInfoWidget(context),
                        accountInfo(context)
                      ],
                    ),
                  )
                ],
              )
          ),
        );
      },
      )
    )
    );
  }

}