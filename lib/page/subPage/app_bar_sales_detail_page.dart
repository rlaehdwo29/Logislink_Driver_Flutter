import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/code_model.dart';
import 'package:logislink_driver_flutter/common/model/sales_manage_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:logislink_driver_flutter/widget/show_select_dialog_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

class AppBarSalesDetailPage extends StatefulWidget {
  SalesManageModel? item;
  String? mode;
  final void Function(bool?) onCallback;

  AppBarSalesDetailPage(this.mode, {Key? key, this.item,required this.onCallback}):super(key: key);

  _AppBarSalesDetailPageState createState() => _AppBarSalesDetailPageState();
}

class _AppBarSalesDetailPageState extends State<AppBarSalesDetailPage> {

  final controller = Get.find<App>();
  ProgressDialog? pr;

  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool regMode = false;
  String? mTitle = "";

  final _selectStartDate = "".obs;
  final _selectEndDate = "".obs;
  final _selectReceipt = "".obs;
  final _selectTax = "".obs;

  final mData = SalesManageModel().obs;
  final mTempData = SalesManageModel().obs;

  late TextEditingController startLocController;
  late TextEditingController endLocController;
  late TextEditingController smOrderCompController;
  late TextEditingController smTruckController;
  late TextEditingController smGoodNameController;
  late TextEditingController smMoneyController;
  late TextEditingController memoController;

  @override
  void initState() {
    super.initState();
    startLocController = TextEditingController();
    endLocController = TextEditingController();
    smOrderCompController = TextEditingController();
    smTruckController = TextEditingController();
    smGoodNameController = TextEditingController();
    smMoneyController = TextEditingController();
    memoController = TextEditingController();
    if(widget.mode == "modi") {
      mData.value = widget.item!;
      mTempData.value = SalesManageModel(
        workId : mData.value?.workId,
        driverId : mData.value?.driverId,
        orderId : mData.value?.orderId,
        visible : mData.value?.visible,
        deposit : mData.value?.deposit,
        depoDate : mData.value?.depoDate,
        regDate : mData.value?.regDate,
        driveDate : mData.value?.driveDate,
        startDate : mData.value?.startDate,
        endDate : mData.value?.endDate,
        orderComp : mData.value?.orderComp,
        truckNetwork : mData.value?.truckNetwork,
        money : mData.value?.money,
        startLoc : mData.value?.startLoc,
        endLoc : mData.value?.endLoc,
        goodsName : mData.value?.goodsName,
        receiptMethod : mData.value?.receiptMethod,
        receiptDate : mData.value?.receiptDate,
        taxMethod : mData.value?.taxMethod,
        taxDate : mData.value?.taxDate,
        memo  :mData.value?.memo,
      );

      _selectStartDate.value = Util.getDateStrToStr(mData.value?.startDate, "yyyy-MM-dd")??"";
      _selectEndDate.value  = Util.getDateStrToStr(mData.value?.endDate, "yyyy-MM-dd")??"";
      _selectReceipt.value = Util.getDateStrToStr(mData.value?.receiptDate,"yyyy-MM-dd") == "-" ? "":Util.getDateStrToStr(mData.value?.receiptDate,"yyyy-MM-dd")!;
      _selectTax.value = Util.getDateStrToStr(mData.value?.taxDate,"yyyy-MM-dd") == "-" ? "" : Util.getDateStrToStr(mData.value?.taxDate,"yyyy-MM-dd")!;
    }else if(widget.mode == "reg"){
      regMode = true;
    }
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    if(regMode) {
      mTitle = Strings.of(context)?.get("Sales_Manage_Modi_title3") ?? "Not Found";
    }else{
      mTitle = Strings.of(context)?.get("Sales_Manage_Modi_title1") ?? "Not Found";
    }
  }

  @override
  void dispose() {
    super.dispose();
    startLocController.dispose();
    endLocController.dispose();
    smOrderCompController.dispose();
    smTruckController.dispose();
    memoController.dispose();
  }

  void selectItem(CodeModel? codeModel,{codeType = "",value = 0}) {
    if(codeType != ""){
      switch(codeType) {
        case 'RECEIPT_KIND':
          if(value == 1) mTempData.value.receiptMethod = codeModel?.codeName??"";
          else if(value == 2)  mTempData.value.taxMethod = codeModel?.codeName??"";
          break;
      }
    }
    setState(() {});
  }

  Future openCalendarDialog(String? _type) {
    _focusedDay = DateTime.now();
    DateTime? _tempSelectedDay = DateTime.now();
    switch(_type) {
      case "startDate" :
        _tempSelectedDay = mTempData.value.startDate == null ? DateTime.now() : DateTime.parse(mTempData.value.startDate!);
        break;
      case "endDate" :
        _tempSelectedDay = mTempData.value.endDate == null ? DateTime.now() : DateTime.parse(mTempData.value.endDate!);
        break;
      case "receipt":
        _tempSelectedDay = mTempData.value.receiptDate == null || mTempData.value.receiptDate?.isEmpty == true? DateTime.now() : DateTime.parse(mTempData.value.receiptDate!);
        break;
      case "tax" :
        _tempSelectedDay = mTempData.value.taxDate == null  || mTempData.value.taxDate?.isEmpty == true ? DateTime.now() : DateTime.parse(mTempData.value.taxDate!);
        break;
    }
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
                        "선택 날짜 : ${_tempSelectedDay == null ?"-":"${_tempSelectedDay?.year}년 ${_tempSelectedDay?.month}월 ${_tempSelectedDay?.day}일"}",
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
                                            switch(_type) {
                                              case "startDate" :
                                                _selectStartDate.value = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat6);
                                                _selectEndDate.value = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat6);
                                                mTempData.value.driveDate = _selectStartDate.value;
                                                mTempData.value.startDate = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat4);
                                                mTempData.value.endDate = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat4);
                                                break;
                                              case "endDate" :
                                                _selectEndDate.value = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat6);
                                                mTempData.value.endDate = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat4);
                                                break;
                                              case "receipt":
                                                _selectReceipt.value = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat6)!;
                                                mTempData.value.receiptDate = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat4);
                                                break;
                                              case "tax" :
                                                _selectTax.value = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat6)!;
                                                mTempData.value.taxDate =Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat4);
                                                break;
                                            }
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

  Widget bodyWidget() {

    startLocController.text = mTempData.value.startLoc??"";
    endLocController.text = mTempData.value.endLoc??"";
    smOrderCompController.text = mTempData.value.orderComp??"";
    smTruckController.text = mTempData.value.truckNetwork??"";
    smGoodNameController.text =  mTempData.value.goodsName??"";
    smMoneyController.text =  mTempData.value.money == null?"0":mTempData.value.money.toString();
    memoController.text = mTempData.value.memo??"";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상차일자
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        Strings.of(context)?.get("Sales_Manage_Start_Date") ??
                            "Not Found",
                        style: CustomStyle.CustomFont(
                            styleFontSize14, text_color_04),
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(right: CustomStyle.getWidth(5.0)),
                        child: Text(
                          Strings.of(context)?.get("Sales_Essential") ??
                              "Not Found",
                          style: CustomStyle.CustomFont(
                              styleFontSize12, text_color_03),
                        ),
                      )
                    ],
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: CustomStyle.customBoxDeco(Colors.white,
                        radius: 5.0, border_color: text_box_color_02),
                    child: InkWell(
                      onTap: () {
                        openCalendarDialog("startDate");
                      },
                      child: Text(
                        _selectStartDate.value.isEmpty ? Strings.of(context)?.get("Sales_Manage_Hint_Load") ?? "Not Found" : _selectStartDate.value,
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize14, main_color),
                      ),
                    ),
                  ))
            ],
          ),
        ),
        // 하차일자
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: Text(
                    Strings.of(context)?.get("Sales_Manage_End_Date") ?? "Not Found",
                    style: CustomStyle.CustomFont(
                        styleFontSize14, text_color_04),
                      ),
                    ),
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: CustomStyle.customBoxDeco(Colors.white,
                        radius: 5.0, border_color: text_box_color_02),
                    child: InkWell(
                      onTap: () {
                        openCalendarDialog("endDate");
                      },
                      child: Text(
                        _selectEndDate.value.isEmpty ? Strings.of(context)?.get("Sales_Manage_Hint_Quit") ?? "Not Found" : _selectEndDate.value,
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize14, main_color),
                      ),
                    ),
                  ))
            ],
          ),
        ),
        // 출발지역
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Strings.of(context)?.get("Sales_Manage_Start_Loc") ?? "Not Found",
                  style: CustomStyle.CustomFont(
                      styleFontSize14, text_color_04),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                    decoration: CustomStyle.customBoxDeco(Colors.white,
                        radius: 5.0, border_color: text_box_color_02),
                    child: TextField(
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.center,
                      controller: startLocController,
                      decoration: startLocController.text.isNotEmpty ? InputDecoration(
                        border: InputBorder.none,
                        hintText: Strings.of(context)?.get("Sales_Manage_Hint_Start") ?? "Not Found",
                        hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                        suffixIcon: IconButton(
                          onPressed: () {
                            startLocController.clear();
                            mTempData.value.startLoc = "";
                          },
                          icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                        ),
                      ) : InputDecoration(
                        border: InputBorder.none,
                        hintText: Strings.of(context)?.get("Sales_Manage_Hint_Start") ?? "Not Found",
                        hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                      ),
                      onChanged: (textValue) {
                        if (textValue.isNotEmpty) {
                          mTempData.value.startLoc = textValue;
                          startLocController.selection = TextSelection.fromPosition(TextPosition(offset: startLocController.text.length));
                        } else {
                          mTempData.value.startLoc = "";
                        }
                      },
                    )
                  ))
            ],
          ),
        ),
        // 도착지역
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Strings.of(context)?.get("Sales_Manage_End_Loc") ?? "Not Found",
                  style: CustomStyle.CustomFont(
                      styleFontSize14, text_color_04),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                      decoration: CustomStyle.customBoxDeco(Colors.white, radius: 5.0, border_color: text_box_color_02),
                      child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textAlignVertical: TextAlignVertical.center,
                        textAlign: TextAlign.center,
                        controller: endLocController,
                        decoration: endLocController.text.isNotEmpty ? InputDecoration(
                          border: InputBorder.none,
                          hintText: Strings.of(context)?.get("Sales_Manage_Hint_End") ?? "Not Found",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                          suffixIcon: IconButton(
                            onPressed: () {
                              endLocController.clear();
                              mTempData.value.endLoc = "";
                            },
                            icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                          ),
                        ) : InputDecoration(
                          border: InputBorder.none,
                          hintText: Strings.of(context)?.get("Sales_Manage_Hint_End") ?? "Not Found",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                        ),
                        onChanged: (textValue) {
                          if (textValue.isNotEmpty) {
                            mTempData.value.endLoc = textValue;
                            endLocController.selection = TextSelection.fromPosition(TextPosition(offset: endLocController.text.length));
                          } else {
                            mTempData.value.endLoc = "";
                          }
                        },
                      )
                  ))
            ],
          ),
        ),
        // 청구업체
        Container(
          margin: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Text(
                        Strings.of(context)?.get("Sales_Manage_Order_Comp") ??
                            "Not Found",
                        style: CustomStyle.CustomFont(
                            styleFontSize14, text_color_04),
                      ),
                      Container(
                        padding:
                        EdgeInsets.only(right: CustomStyle.getWidth(5.0)),
                        child: Text(
                          Strings.of(context)?.get("Sales_Essential") ??
                              "Not Found",
                          style: CustomStyle.CustomFont(
                              styleFontSize12, text_color_03),
                        ),
                      )
                    ],
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                      decoration: CustomStyle.customBoxDeco(Colors.white,
                          radius: 5.0, border_color: text_box_color_02),
                      child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textAlignVertical: TextAlignVertical.center,
                        textAlign: TextAlign.center,
                        controller: smOrderCompController,
                        decoration: smOrderCompController.text.isNotEmpty ? InputDecoration(
                          border: InputBorder.none,
                          hintText: Strings.of(context)?.get("Sales_Manage_Hint_Company") ?? "Not Found",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                          suffixIcon: IconButton(
                            onPressed: () {
                              smOrderCompController.clear();
                              mTempData.value.orderComp = "";
                            },
                            icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                          ),
                        ) : InputDecoration(
                          border: InputBorder.none,
                          hintText: Strings.of(context)?.get("Sales_Manage_Hint_Company") ?? "Not Found",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                        ),
                        onChanged: (textValue) {
                          if (textValue.isNotEmpty) {
                            mTempData.value.orderComp = textValue;
                            smOrderCompController.selection = TextSelection.fromPosition(TextPosition(offset: smOrderCompController.text.length));
                          } else {
                            mTempData.value.orderComp = "";
                          }
                        },
                      )
                  ))
            ],
          ),
        ),
        // 화물정보망
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Strings.of(context)?.get("Sales_Manage_Truck_Network") ?? "Not Found",
                  style: CustomStyle.CustomFont(
                      styleFontSize14, text_color_04),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                      decoration: CustomStyle.customBoxDeco(Colors.white, radius: 5.0, border_color: text_box_color_02),
                      child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textAlignVertical: TextAlignVertical.center,
                        textAlign: TextAlign.center,
                        controller: smTruckController,
                        decoration: smTruckController.text.isNotEmpty ? InputDecoration(
                          border: InputBorder.none,
                          hintText: Strings.of(context)?.get("Sales_Manage_Hint_Web") ?? "Not Found",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                          suffixIcon: IconButton(
                            onPressed: () {
                              smTruckController.clear();
                              mTempData.value.truckNetwork = "";
                            },
                            icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                          ),
                        ) : InputDecoration(
                          border: InputBorder.none,
                          hintText: Strings.of(context)?.get("Sales_Manage_Hint_Web") ?? "Not Found",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                        ),
                        onChanged: (textValue) {
                          if (textValue.isNotEmpty) {
                            mTempData.value.truckNetwork = textValue;
                            smTruckController.selection = TextSelection.fromPosition(TextPosition(offset: smTruckController.text.length));
                          } else {
                            mTempData.value.truckNetwork = "";
                          }
                        },
                      )
                  ))
            ],
          ),
        ),
        // 화물정보
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Strings.of(context)?.get("Sales_Manage_Goods_Name") ?? "Not Found",
                  style: CustomStyle.CustomFont(
                      styleFontSize14, text_color_04),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                      decoration: CustomStyle.customBoxDeco(Colors.white, radius: 5.0, border_color: text_box_color_02),
                      child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textAlignVertical: TextAlignVertical.center,
                        textAlign: TextAlign.center,
                        controller: smGoodNameController,
                        decoration: smGoodNameController.text.isNotEmpty ? InputDecoration(
                          border: InputBorder.none,
                          hintText: Strings.of(context)?.get("Sales_Manage_Hint_Info") ?? "Not Found",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                          suffixIcon: IconButton(
                            onPressed: () {
                              smGoodNameController.clear();
                              mTempData.value.goodsName = "";
                            },
                            icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                          ),
                        ) : InputDecoration(
                          border: InputBorder.none,
                          hintText: Strings.of(context)?.get("Sales_Manage_Hint_Info") ?? "Not Found",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                        ),
                        onChanged: (textValue) {
                          if (textValue.isNotEmpty) {
                            mTempData.value.goodsName = textValue;
                            smGoodNameController.selection = TextSelection.fromPosition(TextPosition(offset: smGoodNameController.text.length));
                          } else {
                            mTempData.value.goodsName = "";
                          }
                        },
                      )
                  ))
            ],
          ),
        ),
        // 운임
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Strings.of(context)?.get("Sales_Manage_Money") ?? "Not Found",
                  style: CustomStyle.CustomFont(
                      styleFontSize14, text_color_04),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.0)),
                      decoration: CustomStyle.customBoxDeco(Colors.white, radius: 5.0, border_color: text_box_color_02),
                      child: Row(
                      children : [
                        Expanded(
                          flex: 8,
                      child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textAlignVertical: TextAlignVertical.center,
                        textAlign: TextAlign.right,
                        controller: smMoneyController,
                        decoration: smMoneyController.text.isNotEmpty ? InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, main_color),
                          suffixIcon: IconButton(
                            onPressed: () {
                              smMoneyController.clear();
                              mTempData.value.money = 0;
                            },
                            icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                          ),
                        ) : InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                          hintStyle: CustomStyle.CustomFont(styleFontSize14, main_color),
                        ),
                        onChanged: (textValue) {
                          if (textValue.isNotEmpty) {
                            mTempData.value.money = int.parse(textValue);
                            smMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: smMoneyController.text.length));
                          } else {
                            mTempData.value.money = 0;
                          }
                        },
                      )
                    ),
                        Expanded(
                          flex: 1,
                            child: Text(
                          Strings.of(context)?.get("Sales_Manage_Won")??"Not Found",
                          style: CustomStyle.CustomFont(styleFontSize16, main_color),
                        )
                        )
                      ])
                  )
              )
            ],
          ),
        ),
        // 인수증정보
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Strings.of(context)?.get("Sales_Manage_Receipt_Method") ?? "Not Found",
                  style: CustomStyle.CustomFont(
                      styleFontSize14, text_color_04),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Row(
                      children : [
                    Expanded(
                      flex: 1,
                        child: InkWell(
                          onTap: () {
                            ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("Sales_Manage_receipt")??"", codeType: Const.RECEIPT_KIND, value: 1, callback: selectItem).showDialog();
                            },
                            child: Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: CustomStyle.customBoxDeco(styleWhiteCol,radius: 5.0,border_color: text_box_color_01),
                            child: Text(
                            mTempData.value.receiptMethod?? Strings.of(context)?.get("Sales_Manage_Hint_Sel")??"Not Found",
                            textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize14, main_color),
                            )
                          ),
                        )
                    ),
                    CustomStyle.sizedBoxWidth(10.0),
                    Expanded(
                      flex: 3,
                        child: Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: CustomStyle.customBoxDeco(Colors.white,
                          radius: 5.0, border_color: text_box_color_02),
                      child: InkWell(
                        onTap: () {
                          openCalendarDialog("receipt");
                        },
                        child: Text(
                          _selectReceipt.value.isEmpty ? Strings.of(context)?.get("Sales_Manage_Hint_Receipt") ?? "Not Found" : _selectReceipt.value,
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(
                              styleFontSize14, main_color),
                        ),
                      ),
                    ))
                  ])
              )
            ],
          ),
        ),
        // 세금계산서
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Strings.of(context)?.get("Sales_Manage_Tax_Method") ?? "Not Found",
                  style: CustomStyle.CustomFont(
                      styleFontSize14, text_color_04),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Row(
                      children : [
                        Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: (){
                                ShowSelectDialogWidget(context:context, mTitle: Strings.of(context)?.get("Sales_Manage_tax")??"", codeType: Const.RECEIPT_KIND, value:2, callback: selectItem).showDialog();
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: CustomStyle.customBoxDeco(styleWhiteCol,radius: 5.0,border_color: text_box_color_01),
                                  child: Text(
                                    mTempData.value.taxMethod?? Strings.of(context)?.get("Sales_Manage_Hint_Sel")??"Not Found",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(styleFontSize14, main_color),
                                  )
                              ),
                            )
                        ),
                        CustomStyle.sizedBoxWidth(10.0),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: CustomStyle.customBoxDeco(Colors.white,
                                  radius: 5.0, border_color: text_box_color_02),
                              child: InkWell(
                                onTap: () {
                                  openCalendarDialog("tax");
                                },
                                child: Text(
                                  _selectTax.value.isEmpty ? Strings.of(context)?.get("Sales_Manage_Hint_Tax") ?? "Not Found" : _selectTax.value,
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(
                                      styleFontSize14, main_color),
                                ),
                              ),
                            ))
                      ])
              )
            ],
          ),
        ),
        // 메모
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: CustomStyle.getHeight(5.0)),
                 child: Text(
                  Strings.of(context)?.get("Sales_Memo") ??
                      "Not Found",
                  textAlign: TextAlign.left,
                  style: CustomStyle.CustomFont(styleFontSize14, text_color_04),
                 )
                ),
              Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: CustomStyle.customBoxDeco(Colors.white,
                        radius: 5.0, border_color: text_box_color_02),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.left,
                      controller: memoController,
                      decoration: memoController.text.isNotEmpty ? InputDecoration(
                        border: InputBorder.none,
                        hintText: Strings.of(context)?.get("Sales_Manage_Hint_Memo")??"Not Found",
                        hintStyle: CustomStyle.CustomFont(styleFontSize14, main_color),
                        suffixIcon: IconButton(
                          onPressed: () {
                            memoController.clear();
                            mTempData.value.memo = "";
                          },
                          icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                        ),
                      ) : InputDecoration(
                        border: InputBorder.none,
                        hintText: Strings.of(context)?.get("Sales_Manage_Hint_Memo")??"Not Found",
                        hintStyle: CustomStyle.CustomFont(styleFontSize14, main_color),
                      ),
                      onChanged: (textValue) {
                        if (textValue.isNotEmpty) {
                          mTempData.value.memo = textValue;
                          memoController.selection = TextSelection.fromPosition(TextPosition(offset: memoController.text.length));
                        } else {
                          mTempData.value.memo = "";
                        }
                      },
                    )
                  )
            ],
          ),
        ),
      ],
    );
  }

  void salesDelete() {
    if(SP.getBoolean(Const.KEY_GUEST_MODE)) {
      showGuestDialog();
      return;
    }
    showDeleteDialog();
  }

  void showDeleteDialog() {
    openCommonConfirmBox(
        context,
        "삭제하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          deleteDataAPI();
        });
  }

  Future<void> deleteDataAPI() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true)
        .invisibleSalesManage(controller.getUserInfo()?.authorization,
            mTempData.value.workId, "N")
        .then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d(
          "deleteDataAPI() _response -> ${response.status} // ${response.resultMap}");
      if (response.status == "200") {
        Util.toast(Strings.of(context)?.get("delete_message")??"Not Found");
        widget.onCallback(true);
        Navigator.of(context).pop(false);
      }else{
        Util.toast("삭제에 실패하였습니다.");
        //openOkBox(context, response.resultMap?["error_message"], Strings.of(context)?.get("close")??"Not Found", () { Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print(
              "deleteDataAPI() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("deleteDataAPI() Error Default => ");
          break;
      }
    });
  }

  void salesCorrect() {
    if(SP.getBoolean(Const.KEY_GUEST_MODE)) {
      showGuestDialog();
      return;
    }
    if(mTempData.value.startDate?.isEmpty == true || mTempData.value.startDate == null) {
      Util.toast("운행일자를 입력해주세요");
      return;
    }
    if(mTempData.value.orderComp?.isEmpty == true || mTempData.value.orderComp == null) {
      Util.toast("청구업체를 입력해주세요");
      return;
    }
    updateDataAPI();
  }

  Future<void> updateDataAPI() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).udpateSalesManage(
        controller.getUserInfo()?.authorization,
        mTempData.value.workId,
        mTempData.value.driveDate,
        mTempData.value.startDate,
        mTempData.value.endDate,
        mTempData.value.startLoc,
        mTempData.value.endLoc,
        mTempData.value.orderComp,
        mTempData.value.truckNetwork,
        mTempData.value.goodsName,
        mTempData.value.money,
        mTempData.value.receiptMethod,
        mTempData.value.receiptDate,
        mTempData.value.taxMethod,
        mTempData.value.taxDate,
        mTempData.value.memo
        ).then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d(
          "updateDataAPI() _response -> ${response.status} // ${response.resultMap}");
      if (response.status == "200") {
        Util.toast(Strings.of(context)?.get("Sales_Mod_Success")??"Not Found");
        widget.onCallback(true);
        Navigator.of(context).pop(false);
      }else{
        Util.toast("수정에 실패하였습니다.");
        //openOkBox(context, response.resultMap?["error_message"], Strings.of(context)?.get("close")??"Not Found", () { Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print(
              "updateDataAPI() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("updateDataAPI() Error Default => ");
          break;
      }
    });
  }

  void salesRegister() {
    if(SP.getBoolean(Const.KEY_GUEST_MODE)) {
      showGuestDialog();
      return;
    }
    if(mTempData.value.startDate?.isEmpty == true || mTempData.value.startDate == null) {
      Util.toast("운행일자를 입력해주세요");
      return;
    }
    if(mTempData.value.orderComp?.isEmpty == true || mTempData.value.orderComp == null) {
      Util.toast("청구업체를 입력해주세요");
      return;
    }
    insertRegisterAPI();
  }

  Future<void> insertRegisterAPI() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).insertSalesManage(
        controller.getUserInfo()?.authorization,
        mTempData.value.driveDate,
        mTempData.value.startDate,
        mTempData.value.endDate,
        mTempData.value.startLoc,
        mTempData.value.endLoc,
        mTempData.value.orderComp,
        mTempData.value.truckNetwork,
        mTempData.value.goodsName,
        mTempData.value.money,
        mTempData.value.receiptMethod,
        mTempData.value.receiptDate,
        mTempData.value.taxMethod,
        mTempData.value.taxDate,
        mTempData.value.memo
    ).then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d(
          "insertRegisterAPI() _response -> ${response.status} // ${response.resultMap}");
      if (response.status == "200") {
        Util.toast(Strings.of(context)?.get("Sales_Reg_Success")??"Not Found");
        widget.onCallback(true);
        Navigator.of(context).pop(false);
      }else{
        Util.toast("등록에 실패하였습니다.");
        //openOkBox(context, response.resultMap?["error_message"], Strings.of(context)?.get("close")??"Not Found", () { Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print(
              "insertRegisterAPI() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("insertRegisterAPI() Error Default => ");
          break;
      }
    });
  }

  void showGuestDialog(){
    openOkBox(context, Strings.of(context)?.get("Guest_Intro_Mode")??"Error", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return Scaffold(
      backgroundColor: styleWhiteCol,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
          child: AppBar(
            centerTitle: true,
            title: Text(
                mTitle??"",
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
          child: Obx((){
            return SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: bodyWidget(),
              )
            );
        })
      ),
        bottomNavigationBar: Row(
        children : [
          // 취소 버튼
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                //salesCancel();
                Navigator.of(context).pop(false);
              },
              child: Container(
                height: 60.0,
                color: cancel_btn,
                padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Text(
                  Strings.of(context)?.get("Sales_Manage_Cancel") ?? "Not Found",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                ),
              ),
            )
          ),
          // 삭제버튼
          !regMode ? Expanded(
              flex: 1,
              child: InkWell(
                onTap: () async {
                  salesDelete();
                },
                child: Container(
                  height: 60.0,
                  color: main_color,
                  padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  child: Text(
                    Strings.of(context)?.get("Sales_Manage_delete") ?? "Not Found",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                  ),
                ),
              )
          ) : const SizedBox(),
          // 수정버튼
          !regMode ? Expanded(
              flex: 1,
              child: InkWell(
                onTap: () async {
                  salesCorrect();
                },
                child: Container(
                  height: 60.0,
                  color: main_color,
                  padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  child: Text(
                    Strings.of(context)?.get("Sales_Manage_Modify") ?? "Not Found",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                  ),
                ),
              )
          ) : const SizedBox(),
          // 등록버튼
          regMode ? Expanded(
              flex: 1,
              child: InkWell(
                onTap: () async {
                  salesRegister();
                },
                child: Container(
                  height: 60.0,
                  color: main_color,
                  padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  child: Text(
                    Strings.of(context)?.get("Sales_Manage_Register") ?? "Not Found",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                  ),
                ),
              )
          ) : const SizedBox()
      ])
    );
  }

}