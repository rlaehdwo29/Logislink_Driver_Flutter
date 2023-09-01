import 'package:fbroadcast/fbroadcast.dart' as fbroad;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/sales_manage_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/page/subPage/app_bar_sales_detail_page.dart';
import 'package:logislink_driver_flutter/provider/appbar_service.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

import '../../common/style_theme.dart';

class AppBarSalesPage extends StatefulWidget {
  _AppBarSalesPageState createState() => _AppBarSalesPageState();
}

class _AppBarSalesPageState extends State<AppBarSalesPage> {

  final controller = Get.find<App>();
  ProgressDialog? pr;

  final isExpanded = [].obs;
  final mList = List.empty(growable: true).obs;

  DateTime _focusedDay = DateTime.now();
  final _rangeStart = DateTime.now().add(const Duration(days: -30)).obs;
  final _rangeEnd = DateTime.now().obs;

  DateTime _depoFocusedDay = DateTime.now();
  final _depoSelectDay = "".obs;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  String? depo_workId = "";
  String? depo_deposit = "";


  @override
  void initState(){
    super.initState();
    _depoSelectDay.value = Util.getDateCalToStr(DateTime.now(), "yyyyMMdd");
    fbroad.FBroadcast.instance().register(Const.INTENT_DEPOSIT, (value, callback) async {
      if(depo_deposit == "Y") {
        showDepositDateDialog();
      }else{
        showDepoDisDialog();
      }
    });
    Util.toast("최대 30일까지 조회 가능합니다.");
  }

  Future<void> onCallback(bool? reload) async {
    print("안타나? =>${reload}");
    if(reload == true){
      await getWork();
    }
    setState(() {});
  }

  Future openCalendarDialog() {
    _focusedDay = DateTime.now();
    DateTime? _tempSelectedDay = null;
    DateTime? _tempRangeStart = _rangeStart.value;
    DateTime? _tempRangeEnd = _rangeEnd.value;
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
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "시작 날짜 : ${_tempRangeStart.isNull?"-":"${_tempRangeStart?.year}년 ${_tempRangeStart?.month}월 ${_tempRangeStart?.day}일"}",
                                style: CustomStyle.CustomFont(
                                    styleFontSize16, styleWhiteCol),
                              ),
                              CustomStyle.sizedBoxHeight(5.0),
                              Text(
                                "종료 날짜 : ${_tempRangeEnd.isNull?"-":"${_tempRangeEnd?.year}년 ${_tempRangeEnd?.month}월 ${_tempRangeEnd?.day}일"}",
                                style: CustomStyle.CustomFont(
                                    styleFontSize16, styleWhiteCol),
                              ),
                            ]
                        )
                    ),
                    content: SingleChildScrollView(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                                children: [
                                  TableCalendar(
                                    firstDay: DateTime.utc(2010, 1, 1),
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
                                    //locale: 'ko_KR',
                                    focusedDay: _focusedDay,
                                    selectedDayPredicate: (day) {
                                      return isSameDay(_tempSelectedDay, day);
                                    },
                                    rangeStartDay: _tempRangeStart,
                                    rangeEndDay: _tempRangeEnd,
                                    calendarFormat: _calendarFormat,
                                    rangeSelectionMode: _rangeSelectionMode,
                                    onDaySelected: (selectedDay, focusedDay) {
                                      if (!isSameDay(_tempSelectedDay, selectedDay)) {
                                        setState(() {
                                          _tempSelectedDay = selectedDay;
                                          _focusedDay = focusedDay;
                                          _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                        });
                                      }
                                    },
                                    onRangeSelected: (start, end, focusedDay) {
                                      print(
                                          "onRangeSelected => ${start} // $end // ${focusedDay}");
                                      setState(() {
                                        _tempSelectedDay = start;
                                        _focusedDay = focusedDay;
                                        _tempRangeStart = start;
                                        _tempRangeEnd = end;
                                        _rangeSelectionMode = RangeSelectionMode.toggledOn;
                                      });
                                    },

                                    onFormatChanged: (format) {
                                      if (_calendarFormat != format) {
                                        setState(() {
                                          _calendarFormat = format;
                                        });
                                      }
                                    },
                                    onPageChanged: (focusedDay) {
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
                                              int? diff_day = _tempRangeEnd?.difference(_tempRangeStart!).inDays;
                                              if(_tempRangeStart == null || _tempRangeEnd == null){
                                                if(_tempRangeStart == null && _tempRangeEnd != null) {
                                                  _tempRangeStart = _tempRangeEnd?.add(const Duration(days: -30));
                                                }else if(_tempRangeStart != null &&_tempRangeEnd == null) {
                                                  DateTime? _tempDate = _tempRangeStart?.add(const Duration(days: 30));
                                                  int start_diff_day = _tempDate!.difference(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day)).inDays;
                                                  if(start_diff_day > 0) {
                                                    _tempRangeEnd = _tempRangeStart;
                                                    _tempRangeStart = _tempRangeEnd?.add(const Duration(days: -30));
                                                  }else{
                                                    _tempRangeEnd = _tempRangeStart?.add(const Duration(days: 30));
                                                  }
                                                }else{
                                                  return Util.toast("시작 날짜 또는 종료 날짜를 선택해주세요.");
                                                }
                                              } else if(diff_day! > 30){
                                                Util.toast(Strings.of(context)?.get("dateOver")??"Not Found");
                                              }else{
                                                _rangeStart.value = _tempRangeStart!;
                                                _rangeEnd.value = _tempRangeEnd!;
                                                Navigator.of(context).pop(false);
                                                //await getWork();
                                              }
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
                        )
                    )
                );
              });
        });
  }

  Widget getListCardView(SalesManageModel item) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AppBarSalesDetailPage("modi",item: item,onCallback: onCallback)));
            },
            child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
                color: styleWhiteCol,
                child: Column(children: [
                  Container(
                      color: order_item_background,
                      child: Column(
                          children: [
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                    flex: 4,
                                    child: Container(
                                        color: styleWhiteCol,
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                            children: [
                                              Container(
                                                  decoration: CustomStyle.customBoxDeco(order_item_background),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: CustomStyle.getHeight(5.0),
                                                      horizontal: CustomStyle.getWidth(10.0)),
                                                  child: Text(
                                                    item.deposit == "N" ? "미지급" : "지급완료",
                                                    style: CustomStyle.CustomFont(
                                                        styleFontSize12,
                                                        item.deposit == "N"?const Color(0xff5050ff) : const Color(0xffff5050)) ,
                                                  )),
                                              Container(
                                                  padding: EdgeInsets.only(
                                                      left: CustomStyle.getWidth(
                                                          10.0),
                                                      right: CustomStyle.getWidth(
                                                          5.0)),
                                                  child: Text(
                                                    "${item.orderComp}",
                                                    style: CustomStyle.CustomFont(
                                                        styleFontSize12,
                                                        main_color),
                                                  )),
                                              Text(
                                                item.truckNetwork?.isEmpty == true || item.truckNetwork == null ? "" : "/ ${item.truckNetwork}",
                                                style: CustomStyle.CustomFont(
                                                    styleFontSize10, main_color),
                                              )
                                            ])
                                    )
                                ),
                                Flexible(
                                    flex: 2,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.all(10.0),
                                      color: styleWhiteCol,
                                      child: InkWell(
                                        onTap: (){
                                          depo_workId = item.workId;
                                          if(item.deposit == "N") {
                                            depo_deposit = "Y";
                                          }else{
                                            depo_deposit = "N";
                                          }
                                          fbroad.FBroadcast.instance().broadcast(Const.INTENT_DEPOSIT);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                                          decoration: CustomStyle.customBoxDeco(order_item_background),
                                          child: Text(
                                            item.deposit == "N" ? "입금확인" : "입금취소",
                                            style: CustomStyle.CustomFont(
                                                styleFontSize12,
                                                item.deposit == "N" ? const Color(0xFFFF5050) : const Color(0xFF5050FF)),
                                          )
                                        )
                                      ),
                                    ))
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(top: CustomStyle.getHeight(10.0)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(children: [
                                      Text(
                                        Util.makeString(item.startLoc)??"Error",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize16, main_color,
                                            font_weight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                      ),
                                      CustomStyle.sizedBoxHeight(5.0),
                                    ]),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Icon(Icons.arrow_forward),
                                  ),
                                  Expanded(
                                      flex: 4,
                                      child: Column(children: [
                                        Text(
                                          Util.makeString(item.endLoc)??"Error",
                                          style: CustomStyle.CustomFont(
                                              styleFontSize16, main_color,
                                              font_weight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        ),
                                        CustomStyle.sizedBoxHeight(5.0),
                                      ]))
                                ],
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(20.0)),
                                margin: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                              CustomStyle.getHeight(5.0),
                                              horizontal:
                                              CustomStyle.getHeight(
                                                  10.0)),
                                          decoration:
                                          CustomStyle.baseBoxDecoWhite(),
                                          child: Text(
                                            "상차 ${item.startDate?.split(" ")[0]}",
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(
                                                styleFontSize10,
                                                text_color_01),
                                          )),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Icon(
                                            Icons.linear_scale_sharp,
                                            color: text_color_01,
                                          )),
                                    ),
                                    Expanded(
                                        flex: 4,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical:
                                                CustomStyle.getHeight(
                                                    5.0),
                                                horizontal:
                                                CustomStyle.getHeight(
                                                    10.0)),
                                            decoration: CustomStyle
                                                .baseBoxDecoWhite(),
                                            child: Text(
                                              "하차 ${item.endDate?.split(" ")[0]}",
                                              textAlign: TextAlign.center,
                                              style: CustomStyle.CustomFont(
                                                  styleFontSize10,
                                                  text_color_01),
                                            )))
                                  ],
                                )
                            )
                          ])),
                  Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: line,
                                        width: CustomStyle.getWidth(1.0)
                                    )
                                )
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Container(
                                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    color: line,
                                                    width: CustomStyle.getWidth(1.0)
                                                )
                                            )
                                        ),
                                        child: Text(
                                          "인수증",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(
                                              styleFontSize12, text_color_01),
                                        )
                                    )
                                ),
                                Expanded(
                                    flex:1,
                                    child: Container(
                                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    color: line,
                                                    width: CustomStyle.getWidth(1.0)
                                                )
                                            )
                                        ),
                                        child: Text(
                                          "세금계산서",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(
                                              styleFontSize12, text_color_01),
                                        )
                                    )
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "입금확인",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(
                                          styleFontSize12, text_color_01),
                                    )
                                ),
                              ],
                            )
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                flex:1,
                                child: Container(
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            right: BorderSide(
                                                color: line,
                                                width: CustomStyle.getWidth(1.0)
                                            )
                                        )
                                    ),
                                    child: Text(
                                      (item.receiptMethod??"").isEmpty || (item.receiptDate == null || item.receiptDate?.isEmpty == true) ?
                                      "-" : "${item.receiptMethod} (${item.receiptDate?.split(" ")[0]})",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(
                                          styleFontSize12, text_color_01),
                                    )
                                )
                            ),
                            Expanded(
                                flex:1,
                                child: Container(
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            right: BorderSide(
                                                color: line,
                                                width: CustomStyle.getWidth(1.0)
                                            )
                                        )
                                    ),
                                    child: Text(
                                      (item.taxMethod??"").isEmpty || (item.taxDate == null || item.taxDate?.isEmpty == true) ?
                                      "-" : "${item.taxMethod} (${item.taxDate?.split(" ")[0]})",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(
                                          styleFontSize12, text_color_01),
                                    )
                                )
                            ),
                            Expanded(
                                flex:1,
                                child: Text(
                                  item.depoDate == null || item.depoDate?.isEmpty == true?
                                  "-" : "${item.depoDate?.split(" ")[0]}",
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(
                                      styleFontSize12, text_color_01),
                                )
                            ),
                          ],
                        )
                      ]
                  )
                ]
                )
            )
        )
    );
  }

  Widget getWorkListWidget() {
    return Expanded(
        child: mList.isNotEmpty
            ? SingleChildScrollView(
            child: Column(
                children: List.generate(
                  mList.length,
                      (index) {
                    var item = mList[index];
                    return getListCardView(item);
                  },
                )))
            : SizedBox(
          child: Center(
              child: Text(
                Strings.of(context)?.get("empty_list") ?? "Not Found",
                style: CustomStyle.CustomFont(styleFontSize20, styleBlackCol1),
              )),
        )
    );
  }

  Future<void> getWork() async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).getSalesManageList(
        controller.getUserInfo()?.authorization,
      Util.getDateCalToStr(_rangeStart.value,'yyyy-MM-dd'),
      Util.getDateCalToStr(_rangeEnd.value,'yyyy-MM-dd')).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getWork() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (mList.isNotEmpty == true) mList.value = List.empty(growable: true);
        if (_response.resultMap?["data"] != null) {
          try {
            var list = _response.resultMap?["data"] as List;
            List<SalesManageModel> itemsList = list.map((i) =>
                SalesManageModel.fromJSON(i)).toList();
            mList?.addAll(itemsList);
          }catch(e) {
            Util.toast("데이터를 가져오는 중 오류가 발생하였습니다.");
          }
        }
      }else{
        mList.value = List.empty(growable: true);
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getWork() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getWork() Error Default => ");
          break;
      }
    });
  }

  Widget itemListFuture() {
    final appBarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
      future: appBarService.getSalesManage(
          context,
          controller.getUserInfo()?.authorization,
          Util.getDateCalToStr(_rangeStart.value,'yyyy-MM-dd'),
          Util.getDateCalToStr(_rangeEnd.value,'yyyy-MM-dd'),
      ),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(mList.isNotEmpty) mList.clear();
          mList.value.addAll(snapshot.data);
          return getWorkListWidget();
        }else if(snapshot.hasError){
          return Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(40.0)),
            alignment: Alignment.center,
            child: Text(
                "${Strings.of(context)?.get("empty_list")}",
                style: CustomStyle.baseFont()),
          );
        }
        return Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            backgroundColor: styleGreyCol1,
          ),
        );
      },
    );
  }

  void showDepoDisDialog(){
    openCommonConfirmBox(
        context,
        "입금처리를 취소겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          _depoSelectDay.value = "";
          await depositDataAPI();
        });
  }

  void showDepositDialog(){
    openCommonConfirmBox(
        context,
        "입금처리를 하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          await depositDataAPI();
        });
  }

  Future<void> depositDataAPI() async {

    Logger logger = Logger();
    await DioService.dioClient(header: true).depositSalesManage(
        App().getUserInfo().authorization,
        depo_workId,
        depo_deposit,
        _depoSelectDay.value).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("depositDataAPI() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
          _depoSelectDay.value = "";
          await getWork();
        }
      }
      setState(() {});
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("depositDataAPI() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("depositDataAPI() Error Default => ");
          break;
      }
    });

  }

  Future showDepositDateDialog() {
    _depoFocusedDay = DateTime.now();
    DateTime? _tempSelectedDay = DateTime.now();
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
                                  focusedDay: _depoFocusedDay,
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
                                        _depoFocusedDay = focusedDay;
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
                                    _depoFocusedDay = focusedDay;
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
                                            _depoSelectDay.value = Util.getDateCalToStr(_tempSelectedDay, Const.dateFormat4);
                                            Navigator.of(context).pop(false);
                                            showDepositDialog();
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

  Widget calendarPanelWidget() {
    isExpanded.value = List.filled(1, true);
    return SingleChildScrollView(
        child: Flex(
          direction: Axis.vertical,
          children: List.generate(1, (index) {
            return ExpansionPanelList.radio(
              animationDuration: const Duration(milliseconds: 500),
              expandedHeaderPadding: EdgeInsets.only(bottom: 0.0.h),
              elevation: 0,
              initialOpenPanelValue: 0,
              children: [
                ExpansionPanelRadio(
                  value: index,
                  backgroundColor: text_color_01,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                        padding: EdgeInsets.only(left: CustomStyle.getWidth(40.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_rounded,size: 20,color: styleWhiteCol,),
                            CustomStyle.sizedBoxWidth(5.0),
                            Text("날짜설정",style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol))
                          ],
                        ));
                  },
                  body: Obx((){
                    return InkWell(
                        onTap: () {
                          openCalendarDialog();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: line,
                                        width: CustomStyle.getWidth(1.0)
                                    )
                                ),
                                color: const Color(0xfffafafa)
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: CustomStyle.getHeight(15.0),horizontal: CustomStyle.getWidth(15.0)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      _rangeStart.value == null ?"-":"${_rangeStart.value?.year}년 ${_rangeStart.value?.month}월 ${_rangeStart.value?.day}일",
                                      textAlign: TextAlign.center,
                                    )
                                ),
                                const Expanded(
                                    flex: 1,
                                    child: Text(
                                      "~",
                                      textAlign: TextAlign.center,
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      _rangeEnd.value  == null?"-":"${_rangeEnd.value?.year}년 ${_rangeEnd.value?.month}월 ${_rangeEnd.value?.day}일",
                                      textAlign: TextAlign.center,
                                    )
                                )
                              ],
                            )
                        )
                    );
                  }),
                  canTapOnHeader: true,
                )
              ],
              expansionCallback: (int _index, bool status) {
                isExpanded[index] = !isExpanded[index];
                //for (int i = 0; i < isExpanded.length; i++)
                //  if (i != index) isExpanded[i] = false;
              },
            );
          }),
        )
    );
  }

  void goToSalesReg(){
    if(SP.getBoolean(Const.KEY_GUEST_MODE)??false) {
      showGuestDialog();
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => AppBarSalesDetailPage("reg",item: null,onCallback: onCallback)));
  }

  void showGuestDialog(){
    openOkBox(context, Strings.of(context)?.get("Guest_Intro_Mode")??"Error", Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return Scaffold(
      backgroundColor: order_item_background,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
          child: AppBar(
            centerTitle: true,
            title: Text(
                Strings.of(context)?.get("Sales_Manage_Title") ?? "Not Found",
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
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  calendarPanelWidget(),
                  itemListFuture()
                ]
            );
          })
      ),
        bottomNavigationBar: InkWell(
          onTap: () async {
            goToSalesReg();
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
    );
  }
  
}