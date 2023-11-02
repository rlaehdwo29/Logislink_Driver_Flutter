import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/bank_info_model.dart';
import 'package:logislink_driver_flutter/common/model/code_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:logislink_driver_flutter/widget/show_select_dialog_widget.dart';
import 'package:dio/dio.dart';

class ShowBankCheckWidget{

  final BuildContext context;
  final controller = Get.find<App>();
  final void Function(String?,String?,String?) callback;

  ShowBankCheckWidget({required this.context, required this.callback});

  final mData = BankInfoModel().obs;
  final tempData = BankInfoModel().obs;
  final bank_Nm = "".obs;
  final isChecked = false.obs;
  final isLoading = false.obs;

  void selectItem(CodeModel? codeModel,{codeType = "",value = 0}) {
    bank_Nm.value = codeModel?.codeName??"";
    mData.value?.bankCd = codeModel?.code;
  }

  Future showBankCheckDialog(UserModel mUser) {

    var _controller = TextEditingController();
    UserModel? user = mUser;
    mData.value = BankInfoModel(bankCd: user?.bankCode,acctNm: user?.bankCnnm, acctNo: user?.bankAccount, chkDate: user?.bankchkDate);
    tempData.value = BankInfoModel(bankCd: mData.value?.bankCd,acctNm: mData.value?.acctNm, acctNo: mData.value?.acctNo, chkDate: mData.value?.chkDate);
    _controller.text = tempData.value?.acctNo ?? "";
    bank_Nm.value = getBankName(tempData.value?.bankCd)??"";
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context ){
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                    contentPadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    titlePadding: EdgeInsets.all(CustomStyle.getWidth(0.0)),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0.0))
                    ),
                    title: Container(
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0),horizontal: CustomStyle.getWidth(5.0)),
                        decoration: CustomStyle.customBoxDeco(main_color,radius: 0),
                        child: Text(
                          '${Strings.of(context)?.get("bank_info_edit")}',
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                        )
                    ),
                    content: Obx((){
                      return SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  margin: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: CustomStyle.borderAllBase(),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            color: line,
                                                            width: CustomStyle.getWidth(1.0)
                                                        ),
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
                                                child: InkWell(
                                                    onTap: (){
                                                      //showBank(Strings.of(context)?.get("bank_name"),BANK_CD);
                                                      ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("bank_name")??"", codeType: Const.BANK_CD, callback: selectItem).showDialog();
                                                    },
                                                    child: Container(
                                                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15)),
                                                        decoration: BoxDecoration(
                                                            border: Border(
                                                              bottom: BorderSide(
                                                                  color: line,
                                                                  width: CustomStyle.getWidth(1.0)
                                                              ),
                                                              left: BorderSide(
                                                                color: line,
                                                                width: CustomStyle.getWidth(1.0)
                                                            ),
                                                            )
                                                        ),
                                                        child: Text(
                                                          "$bank_Nm",
                                                          textAlign: TextAlign.center,
                                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                        )
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
                                                child: SizedBox(
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
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            left: BorderSide(
                                                                color: line,
                                                                width: CustomStyle.getWidth(1.0)
                                                            )
                                                        )
                                                    ),
                                                    child: TextField(
                                                      maxLines: 1,
                                                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                                      controller: _controller,
                                                      maxLength: 20,
                                                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                                      autofocus: false,
                                                      keyboardType: TextInputType.number,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          if(value.isNotEmpty) {
                                                            mData.value?.acctNo = value;
                                                            if(mData.value?.chkDate?.isEmpty != true){
                                                              isChecked.value = mData == tempData ? true:false;
                                                            }
                                                          }else{
                                                            mData.value?.acctNo = "";
                                                            isChecked.value = false;
                                                          }
                                                        });
                                                      },
                                                      textAlignVertical: TextAlignVertical.center,
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        counterText: '',
                                                        contentPadding: EdgeInsets.symmetric(
                                                            horizontal: CustomStyle.getWidth(10.0),
                                                            vertical: CustomStyle.getHeight(0.0)
                                                        ),
                                                        suffixIcon: _controller.text.isNotEmpty ? IconButton(
                                                          onPressed: _controller.clear,
                                                          icon: const Icon(Icons.clear,size: 15),
                                                        ) : const SizedBox(),
                                                      ),
                                                    )
                                                )
                                            )
                                          ]
                                      )
                                    ],
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                                  child: Text(
                                    "* 계좌번호는 숫자만 입력 (공백,-,/ 등 없이)",
                                    textAlign: TextAlign.left,
                                    style: CustomStyle.CustomFont(styleFontSize10, text_color_01),
                                  )
                              ),
                              Row(
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                            onTap: () async {
                                              if(isChecked.value == false) {
                                                FocusManager.instance.primaryFocus?.unfocus();
                                                await getIaccNm();
                                              }
                                            },
                                            child: Container(
                                                decoration: CustomStyle.customBoxDeco(!isChecked.value?sub_color:text_color_02,radius: 15,border_color: text_color_02),
                                                padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                                margin: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0), vertical: CustomStyle.getHeight(10.0)),
                                                child:Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                  Text(
                                                    !isChecked.value? Strings.of(context)?.get("bank_check")??"Not Found" : "예금주 확인완료",
                                                    textAlign: TextAlign.center,
                                                    style: CustomStyle.CustomFont(styleFontSize12,styleWhiteCol),
                                                  ),
                                                    isLoading.value == true? Container(
                                                        margin: EdgeInsets.only(left: CustomStyle.getWidth(5.0)),
                                                        child: SpinKitFadingCircle(
                                                          color: Colors.white,
                                                          size: 20.0,
                                                      )
                                                    ):const SizedBox()
                                                  ]
                                                ),
                                            )
                                        )
                                    )
                                  ]
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    border: CustomStyle.borderAllBase(),
                                  ),
                                  margin: EdgeInsets.only(left: CustomStyle.getWidth(10.0),right: CustomStyle.getWidth(10.0), bottom: CustomStyle.getHeight(10.0)),
                                  child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0)),
                                              child: Text(
                                                Strings.of(context)?.get("bank_cnnm")??"Not Found",
                                                textAlign: TextAlign.center,
                                                style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                              ),
                                            )
                                        ),
                                        Expanded(
                                            flex: 3,
                                            child: InkWell(
                                                onTap: (){

                                                },
                                                child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0),horizontal: CustomStyle.getWidth(10.0)),
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                          left: BorderSide(
                                                              color: line,
                                                              width: CustomStyle.getWidth(1.0)
                                                          ),
                                                        )
                                                    ),
                                                    child: Text(
                                                      "${tempData.value?.acctNm}",
                                                      textAlign: TextAlign.left,
                                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                                    )
                                                )
                                            )
                                        )
                                      ]
                                  )
                              ),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        flex:1,
                                        child: InkWell(
                                            onTap: (){
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                                height:CustomStyle.getHeight(50.0),
                                                color: cancel_btn,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  Strings.of(context)?.get("cancel")??"Not Found",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                                                )
                                            )
                                        )
                                    ),
                                    Expanded(
                                        flex:1,
                                        child: InkWell(
                                            onTap: () async {
                                              if(isChecked.value) await bank_check_confirm();
                                              else Util.toast("예금주 확인을 진행해주세요.");
                                            },
                                            child: Container(
                                                height:CustomStyle.getHeight(50.0),
                                                color: main_color,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  Strings.of(context)?.get("confirm")??"Not Found",
                                                  textAlign: TextAlign.center,
                                                  style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
                                                )
                                            )
                                        )
                                    )
                                  ]
                              )
                            ]
                        )
                    );
                  })
                );
              }
          );
        }
    );


  }

  String? getBankName(String? code) {
    return SP.getCodeName(Const.BANK_CD, code!);
  }

  Future<void> getIaccNm() async {
    UserModel? user = await controller.getUserInfo();
    if(mData.value?.bankCd == null || mData.value?.bankCd == "") {
      Util.toast("은행명을 선택해 주세요.");
      return;
    }
    if(mData.value?.acctNo == null || mData.value?.acctNo == "") {
      Util.toast("계좌번호를 입력해 주세요.");
      return;
    }
    if(isChecked.value){
      return;
    }
    isLoading.value = true;
    Logger logger = Logger();
    await DioService.dioClient(header: true).getIaccNm(user?.authorization, user?.vehicId, mData.value?.bankCd, mData.value?.acctNo).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getIaccNm() _response -> ${_response.status} // ${_response.resultMap}");
      isLoading.value = false;
      if(_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          isChecked.value = true;
          mData.value.acctNm = _response.resultMap?["iacctNm"];
          mData.value.chkDate = Util.getCurrentDate("yyyyMMdd");
          tempData.value = BankInfoModel(bankCd: mData.value?.bankCd,
              acctNm: mData.value?.acctNm,
              acctNo: mData.value?.acctNo,
              chkDate: mData.value?.chkDate);
        }else{
          isChecked.value = false;
          Util.toast("${_response.resultMap?["msg"]}");
        }
        }else{
        Util.toast(_response.message);
      }
    }).catchError((Object obj) {
      isLoading.value = false;
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

  Future<void> bank_check_confirm() async {
    //if(isChecked.value){
      await updateBank();
    //}else{
    //  Util.toast("예금주를 확인해주세요.");
    //}
  }

  Future<void> updateBank() async {
    UserModel? user = await controller.getUserInfo();
    Logger logger = Logger();
    await DioService.dioClient(header: true).updateBank(user?.authorization, mData.value?.bankCd, mData.value.acctNm, mData.value?.acctNo).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
        logger.d("updateBank() _response -> ${_response.status} // ${_response.resultMap}");
        if (_response.status == "200") {
          Util.toast("계좌정보가 등록되었습니다.");
          callback(mData.value?.bankCd, mData.value?.acctNm, mData.value?.acctNo);
          Navigator.pop(context);
        } else {
          Util.toast(_response.message);
        }
    }).catchError((Object obj) {
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

}