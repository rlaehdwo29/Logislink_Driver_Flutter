import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/order_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/page/subPage/appbar_mypage.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:logislink_driver_flutter/widget/show_bank_check_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

class TaxPage extends StatefulWidget {
  OrderModel? item;

  TaxPage({Key? key,this.item}):super(key: key);

  _TaxPageState createState() => _TaxPageState();
}
class _TaxPageState extends State<TaxPage> {

  final controller = Get.find<App>();
  final tvFee = "".obs;
  final tvCharge = "".obs;
  final tvPrice = "".obs;
  final tvTax = "".obs;
  final tvTotalPrice = "".obs;
  final _isChecked = false.obs;
  final pay = false.obs;
  final app = UserModel().obs;


  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final _selectDay = DateTime.now().obs;

  ProgressDialog? pr;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      app.value = await controller.getUserInfo();
    });
    initView();
  }

  void _callback(String? bankCd, String? acctNm, String? acctNo) {
    setState(() async {
      UserModel user = await controller.getUserInfo()!;
      user?.bankCode = bankCd;
      user?.bankCnnm = acctNm;
      user?.bankAccount = acctNo;
      controller.setUserInfo(user);
    });
  }

  void onCallback(bool? refresh) {
    setState(() async {
      if (refresh != null) {
        if (refresh) {
          app.value = await controller.getUserInfo();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':100});
          return false;
        } ,
        child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
            child: AppBar(
              centerTitle: true,
              title: Text(Strings.of(context)?.get("tax_title") ?? "Not Found",
                  style: CustomStyle.appBarTitleFont(
                      styleFontSize18, styleWhiteCol)),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop({'code':100});
                },
                color: styleWhiteCol,
                icon: const Icon(Icons.arrow_back),
              ),
            )),
        body: Obx((){
        return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                    color: styleWhiteCol,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        topWidget(context),
                        businessInfoWidget(context),
                        priceInfoWidget(context),
                        accountInfo(context),
                        Container(
                          padding: EdgeInsets.only(top: CustomStyle.getHeight(10.0)),
                          child: Text(
                            Strings.of(context)?.get("tax_info")??"Not Found",
                            style: CustomStyle.CustomFont(styleFontSize10, addr_zip_no),
                          )
                        )
                      ]
                )
              )
            )
        );
        }),
        bottomNavigationBar: InkWell(
          onTap: () async {
            sendTax();
          },
          child: Container(
            height: 60.0,
            color: main_color,
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            child: Text(
              Strings.of(context)?.get("tax_btn") ?? "Not Found",
              textAlign: TextAlign.center,
              style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
            ),
          ),
        )));
  }

  void initView() {
    //setCalendar();
    setPrice();
  }

  bool validation() {
    if(app.value.driverEmail?.isEmpty == true) {
      Util.toast("등록된 이메일이 없습니다.");
      return false;
    }
    if(app.value.bizNum?.isEmpty == true &&
        app.value.bizName?.isEmpty == true &&
        app.value.ceo?.isEmpty == true &&
        app.value.bizAddr?.isEmpty == true &&
        app.value.bizCond?.isEmpty == true &&
        app.value.bizKind?.isEmpty == true) {
      Util.toast("등록된 사업자정보가 없거나 정확하지 않습니다");
      return false;
    }
    if(app.value.bankAccount?.isEmpty == true &&
        app.value.bankCnnm?.isEmpty == true &&
        app.value.bankCode?.isEmpty == true) {
      Util.toast("등록된 계좌가 없습니다.");
    }
    if(app.value.bankchkDate == null) {
      Util.toast("확인되지 않은 계좌입니다.");
      return false;
    }
    return true;
  }

  void sendTax() {
    if(validation()) {
      if(widget.item?.payType == "Y") {
        if(widget.item?.reqPayYN == "N") {
          showIsPayDialog();
          return;
        }
      }
      showTax();
    }
  }

  void showIsPayDialog() {
    openCommonConfirmBox(
        context,
        "해당 오더는 빠른지급신청이 가능합니다.\n빠른지급을 신청하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {
          Navigator.of(context).pop(false);
          showTax();
          },
            () async {
          Navigator.of(context).pop(false);
          showPayDialog(await showPayConfirm);
        }
    );
  }

  void showTax() {
    openCommonConfirmBox(
        context,
        "[${widget.item?.sellCustName}] \n\n 전자세금계산서를 발행 하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {
          Navigator.of(context).pop(false);
        },
            () async {
              Navigator.of(context).pop(false);
          if(widget.item?.invId?.isNotEmpty == true) {
            if(widget.item?.loadStatus == "0") {
              await issueTax();
            }else if(widget.item?.loadStatus == "1") {
              Util.toast("전자세금계산서 발행 요청중입니다.");
            }
          }else{
            await writeTax();
          }
        }
    );
  }

  Future<void> writeTax() async {
    Logger logger = Logger();
    await pr?.show();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).writeTax(app.authorization, widget.item?.orderId, widget.item?.allocId, "02", app.vehicId, Util.getDateCalToStr(_selectDay.value, "yyyyMMdd")).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("writeTax() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
            widget.item?.invId = it.response.data["invId"];
            issueTax();
        } else {
          Util.toast(_response.resultMap?["msg"]);
        }
      }else{
        Util.toast(_response.message);
      }

    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("tax_page.dart writeTax() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("tax_page.dart writeTax() Error Default:");
          break;
      }
    });
  }

  Future<void> issueTax() async {
    Logger logger = Logger();
    await pr?.show();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).issueTax(app.authorization, widget.item?.invId, app.vehicId).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      if(_response.status == "200") {
        Navigator.of(context).pop({'code':200});
      }else{
        Util.toast(_response.message);
      }

    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("tax_page.dart issueTax() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("tax_page.dart issueTax() Error Default:");
          break;
      }
    });
  }

  Future<void> showPayConfirm(String? _result) async {
    if(_result == "200") {
      var result = await checkBankDate();
      if(result != true) {
        sendPay();
      }else{
        checkAccNm();
      }
    }
  }

  Future<void> checkAccNm() async {
    Logger logger = Logger();
    await pr?.show();
    var app = await controller.getUserInfo();
    await DioService.dioClient(header: true).checkAccNm(app.authorization, app.vehicId, app.bankCode,app.bankAccount, app.bankCnnm).then((it) async {
    await pr?.hide();
    ReturnMap _response = DioService.dioResponse(it);
    if(_response.status == "200") {
      if (_response.resultMap?["result"] == true) {
        updateBank();
      } else {
        openOkBox(context, _response.resultMap?["msg"], Strings.of(context)?.get("close") ?? "Not Found", () => Navigator.of(context).pop(false));
      }
    }else{
      Util.toast(_response.message);
    }

    }).catchError((Object obj) async {
    await pr?.hide();
    switch (obj.runtimeType) {
    case DioError:
    // Here's the sample to get the failed response error code and message
    final res = (obj as DioError).response;
    logger.e("tax_page.dart issueTax() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
    openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
    break;
    default:
    logger.e("tax_page.dart issueTax() Error Default:");
    break;
    }
    });
  }

  Future<void> updateBank() async {
    Logger logger = Logger();
    var app = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).updateBank(app.authorization, app.bankCode, app.bankCnnm, app.bankAccount).then((it) async {
    await pr?.hide();
    ReturnMap _response = DioService.dioResponse(it);
    if(_response.status == "200") {
      if (_response.resultMap?["result"] == true) {
        UserModel user = await controller.getUserInfo();
        user.bankchkDate = Util.getCurrentDate("yyyy-MM-dd HH:mm:ss");
        controller.setUserInfo(user);
        sendPay();
      } else {
        openOkBox(context, _response.resultMap?["msg"], Strings.of(context)?.get("close") ?? "Not Found", () => Navigator.of(context).pop(false));
      }
    }else{
      Util.toast(_response.message);
    }
    }).catchError((Object obj) async {
    await pr?.hide();
    switch (obj.runtimeType) {
    case DioError:
    // Here's the sample to get the failed response error code and message
    final res = (obj as DioError).response;
    logger.e("tax_page.dart issueTax() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
    openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
    break;
    default:
    logger.e("tax_page.dart issueTax() Error Default:");
    break;
    }
    });
  }

  void confirm(Function(String?) _showPayCallback) {
    if(_isChecked.value){
      _showPayCallback("200");
      Navigator.of(context).pop();
    }else{
      Util.toast("빠른지급신청에 동의해주세요.");
    }
  }

  Future<bool?> checkBankDate() async {
    UserModel? user = await controller.getUserInfo();
    String? nowDate = Util.getCurrentDate("yyyyMMdd");
    String? saveDate = Util.getDateStrToStr(user?.bankchkDate, "yyyyMMdd");
    return Util.betweenDate(nowDate, saveDate)! > 30;
  }

  Future<void> sendPay() async {
    Logger logger = Logger();
    var app = await controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).sendPay(app.authorization, app.vehicId, widget.item?.orderId, widget.item?.allocId).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      if(_response.status == "200") {
        widget.item?.reqPayYN = "Y";
        Util.toast("빠른지급 신청이 완료되었습니다.");
        Navigator.of(context).pop();
      }else{
        Util.toast(_response.message);
      }

    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("tax_page.dart getIaccNm() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("tax_page.dart getIaccNm() Error Default:");
          break;
      }
    });

  }

  Future<void> showPayDialog(Function(String?) _showPayCallback) async {
    _isChecked.value = false;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {

          String fee = Util.getPayFee(widget.item?.sellCharge, widget.item?.reqPayFee);
          String charge = Util.getInCodeCommaWon(Util.getPayCharge(widget.item?.sellCharge, fee));

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
                                            "(사용료 ${Util.getInCodeCommaWon(Util.getPayFee(widget.item?.sellCharge, widget.item?.reqPayFee))}원 제외)",
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
                                        "일반운임 : ${Util.getInCodeCommaWon(widget.item?.sellCharge)}원",
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
                                          Navigator.pop(context);
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

  Future openCalendarDialog() {
    _focusedDay = DateTime.now();
    DateTime? _tempSelectedDay = _selectDay.value;
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
                  title: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0),horizontal: CustomStyle.getWidth(15.0)),
                      color: main_color,
                      child: Text(
                              "선택 날짜 : ${_tempSelectedDay == null?"-":"${_tempSelectedDay?.year}년 ${_tempSelectedDay?.month}월 ${_tempSelectedDay?.day}일"}",
                              style: CustomStyle.CustomFont(
                                  styleFontSize16, styleWhiteCol),
                            ),
                  ),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          TableCalendar(
                              focusedDay: _focusedDay,
                              firstDay:  DateTime.utc(2010, 1, 1),
                              lastDay: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                            headerStyle: const HeaderStyle(
                              // default로 설정 돼 있는 2 weeks 버튼을 없애줌 (아마 2주단위로 보기 버튼인듯?)
                              formatButtonVisible: false,
                              // 달력 타이틀을 센터로
                              titleCentered: true,
                              // 말 그대로 타이틀 텍스트 스타일링
                              titleTextStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                              ),
                            ),
                            calendarStyle: CalendarStyle(
                              // 오늘 날짜에 하이라이팅의 유무
                              isTodayHighlighted: false,
                              // 캘린더의 평일 배경 스타일링(default면 평일을 의미)
                              defaultDecoration: BoxDecoration(
                                color: order_item_background,
                                shape: BoxShape.rectangle,
                              ),
                              // 캘린더의 주말 배경 스타일링
                              weekendDecoration:  BoxDecoration(
                                color: order_item_background,
                                shape: BoxShape.rectangle,
                              ),
                              // 선택한 날짜 배경 스타일링
                              selectedDecoration: BoxDecoration(
                                  color: styleWhiteCol,
                                  shape: BoxShape.rectangle,
                                  border: Border.all(color: sub_color)
                              ),
                              defaultTextStyle: CustomStyle.CustomFont(
                                  styleFontSize14, Colors.black),
                              weekendTextStyle:
                              CustomStyle.CustomFont(styleFontSize14, Colors.red),
                              selectedTextStyle: CustomStyle.CustomFont(
                                  styleFontSize14, Colors.black),
                              // range 크기 조절
                              rangeHighlightScale: 1.0,

                              // range 색상 조정
                              rangeHighlightColor: const Color(0xFFBBDDFF),

                              // rangeStartDay 글자 조정
                              rangeStartTextStyle: CustomStyle.CustomFont(
                                  styleFontSize14, Colors.black),

                              // rangeStartDay 모양 조정
                              rangeStartDecoration: BoxDecoration(
                                  color: styleWhiteCol,
                                  shape: BoxShape.rectangle,
                                  border: Border.all(color: sub_color)
                              ),

                              // rangeEndDay 글자 조정
                              rangeEndTextStyle: CustomStyle.CustomFont(
                                  styleFontSize14, Colors.black),

                              // rangeEndDay 모양 조정
                              rangeEndDecoration: BoxDecoration(
                                  color: styleWhiteCol,
                                  shape: BoxShape.rectangle,
                                  border: Border.all(color: sub_color)
                              ),

                              // startDay, endDay 사이의 글자 조정
                              withinRangeTextStyle: const TextStyle(),

                              // startDay, endDay 사이의 모양 조정
                              withinRangeDecoration:
                              const BoxDecoration(),
                            ),
                            selectedDayPredicate: (day) {
                              return isSameDay(_tempSelectedDay, day);
                            },
                            calendarFormat: _calendarFormat,
                            onDaySelected: (selectedDay, focusedDay) {
                              print("onDaySelected => ${selectedDay} // ${focusedDay}");
                              if (!isSameDay(_tempSelectedDay, selectedDay)) {
                                setState(() {
                                  _tempSelectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              }
                            },
                            onFormatChanged: (format) {
                              print("onFormatChanged => ${format}");
                              if (_calendarFormat != format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              }
                            },
                            onPageChanged: (focusedDay) {
                              print("onPageChanged => ${focusedDay}");
                              _focusedDay = focusedDay;
                            },
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      Strings.of(context)?.get("cancel")??"Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
                                    )
                                ),
                                CustomStyle.sizedBoxWidth(CustomStyle.getWidth(15.0)),
                                TextButton(
                                    onPressed: () async {
                                      _selectDay.value = _tempSelectedDay!;
                                      Navigator.of(context).pop(false);
                                      setState((){});
                                    },
                                    child: Text(
                                      Strings.of(context)?.get("confirm")??"Not Found",
                                      style: CustomStyle.CustomFont(styleFontSize14, styleBlackCol1),
                                    )
                                )
                              ],
                            ),
                          )
                        ]
                      )
                    ),
                  )
                );
              }
          );
        }
    );
  }

  void setPrice() {
    int charge, fee, price, tax, totalPrice;
    charge = int.parse(widget.item?.sellCharge??"");
    fee = 0;
    price = charge - fee;
    if(widget.item?.payType == "Y") {
      if(widget.item?.reqPayYN == "Y") {
        fee = int.parse(Util.getPayFee(widget.item?.sellCharge, widget.item?.reqPayFee));
        price = int.parse(Util.getPayCharge(widget.item?.sellCharge, fee.toString()));
        tvFee.value = Util.getInCodeCommaWon(fee.toString());
      }
    }

    pay.value = widget.item?.reqPayYN == "Y"?true:false;

    tax = price ~/ 10;
    totalPrice = price + tax;
    tvCharge.value =  Util.getInCodeCommaWon(charge.toString());
    tvPrice.value = Util.getInCodeCommaWon(price.toString());
    tvTax.value = Util.getInCodeCommaWon(tax.toString());
    tvTotalPrice.value = Util.getInCodeCommaWon(totalPrice.toString());
  }

  String getBankName(String? code) {
    return SP.getCodeName(Const.BANK_CD, code??"");
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
                                  getBankName(app.value.bankCode),
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
                                  "${app.value.bankAccount}",
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
                                  "${app.value.bankCnnm}",
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

  String? makeBizNum(String num){
    if(num == null || num.isEmpty) {
      return num;
    }else{
      return Util.makeBizNum(num);
    }
  }

  Widget priceInfoWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: line, width: CustomStyle.getWidth(0.5)
              )
            )
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                  child: Text(
                    "작성일자",
                    textAlign: TextAlign.start,
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
              ),
              Expanded(
                flex: 3,
                  child: InkWell(
                    onTap: (){
                      openCalendarDialog();
                    },
                    child: Text(
                      Util.getDateCalToStr(_selectDay.value, 'yyyy-MM-dd'),
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                    ),
                  )
              ),
              InkWell(
                onTap: (){
                  openCalendarDialog();
                },
                child: Icon(Icons.calendar_today_rounded,color: styleDefaultGrey, size: 24,)
              )
            ],
          )
          ),
            Container(
              padding:
                  EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: line, width: CustomStyle.getWidth(0.5)))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("금액", textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize14, text_color_01)),
                  Text("${tvCharge.value}원",textAlign: TextAlign.center,style: CustomStyle.CustomFont(styleFontSize14, text_color_01),)
                ],
              ),
            ),
          pay.value ? Container(
            padding:
            EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: line, width: CustomStyle.getWidth(0.5)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("서비스 사용료", textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize14, text_color_01)),
                Text("${tvFee.value}원",textAlign: TextAlign.center,style: CustomStyle.CustomFont(styleFontSize14, text_color_01),)
              ],
            ),
          ):Container(),
          Container(
            padding:
            EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: line, width: CustomStyle.getWidth(0.5)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("공급가액", textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize14, text_color_01)),
                Text("${tvPrice.value}원",textAlign: TextAlign.center,style: CustomStyle.CustomFont(styleFontSize14, text_color_01),)
              ],
            ),
          ),
          Container(
            padding:
            EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: line, width: CustomStyle.getWidth(0.5)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("세액", textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize14, text_color_01)),
                Text("${tvTax.value}원",textAlign: TextAlign.center,style: CustomStyle.CustomFont(styleFontSize14, text_color_01),)
              ],
            ),
          ),
          Container(
            padding:
            EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: line, width: CustomStyle.getWidth(0.5)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("총액", textAlign: TextAlign.center, style: CustomStyle.CustomFont(styleFontSize14, text_color_01)),
                Text("${tvTotalPrice.value}원",textAlign: TextAlign.center,style: CustomStyle.CustomFont(styleFontSize14, text_color_01),)
              ],
            ),
          )
          ],
      )
    );
  }

  Widget businessInfoWidget(BuildContext context) {
    return Container(
      decoration: CustomStyle.customBoxDeco(styleWhiteCol, border_color: line,radius: 0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: line, width: CustomStyle.getWidth(0.5)),
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
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("biz_num")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child:Text(
                          "${makeBizNum(app.value.bizNum??"")}",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
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
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("sub_biz_num")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child:Text(
                          "${app.value.subBizNum}",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: line, width: CustomStyle.getWidth(0.5)),
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
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("biz_name")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child:Text(
                          "${app.value.bizName}",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: line, width: CustomStyle.getWidth(0.5)),
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
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("ceo")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child:Text(
                          "${app.value.ceo}",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: line, width: CustomStyle.getWidth(0.5)),
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
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("addr")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child:Text(
                          "${app.value.bizAddr}",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: line, width: CustomStyle.getWidth(0.5)),
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
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("addr_detail")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child:Text(
                          "${app.value.bizAddrDetail}",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: line, width: CustomStyle.getWidth(0.5)),
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
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("biz_cond")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
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
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child:Text(
                          "${app.value.bizCond}",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("biz_kind")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child:Text(
                          "${app.value.bizKind}",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: line, width: CustomStyle.getWidth(0.5)),
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
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("driver_email")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                ),
                Expanded(
                    flex: 4,
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child:Text(
                          "${app.value.driverEmail}",
                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                        )
                    )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget topWidget(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: CustomStyle.getHeight(10.0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Strings.of(context)?.get("tax_sub_title_01")??"Not Found",
              style: CustomStyle.CustomFont(styleFontSize16, text_color_01),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: sub_color,
                  onPrimary: main_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AppBarMyPage(code:"edit_biz",onCallback: onCallback,)));
                },
                child: Text(
                  Strings.of(context)?.get("tax_biz_edit")??"Not Fount",
                  style: CustomStyle.CustomFont(styleFontSize10, styleWhiteCol),
                )
            )
          ],
        )
    );
  }
  
}