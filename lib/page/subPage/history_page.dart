import 'package:fbroadcast/fbroadcast.dart' as fbroad;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/page/subPage/order_detail_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/provider/order_service.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../common/model/order_model.dart';
import 'package:dio/dio.dart';

class HistoryPage extends StatefulWidget {
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  final isExpanded = [].obs;
  final isSelected = [].obs;
  final controller = Get.find<App>();

  final receiptYn = "".obs;
  final taxYn = "".obs;
  final payType = "".obs;
  final payYn = "".obs;

  DateTime _focusedDay = DateTime.now();
  final _rangeStart = DateTime.now().add(const Duration(days: -30)).obs;
  final _rangeEnd = DateTime.now().obs;

  final _historyList = List.empty(growable: true).obs;

  final GlobalKey webViewKey = GlobalKey();
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();
    Util.toast("최대 30일까지 조회 가능합니다.");
    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue,),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController.loadUrl(urlRequest: URLRequest(url: await webViewController.getUrl()));}
      },
    ))!;
  }

  @override
  void dispose() {
    super.dispose();
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
                          "시작 날짜 : ${_tempRangeStart == null?"-":"${_tempRangeStart?.year}년 ${_tempRangeStart?.month}월 ${_tempRangeStart?.day}일"}",
                          style: CustomStyle.CustomFont(
                              styleFontSize16, styleWhiteCol),
                        ),
                        CustomStyle.sizedBoxHeight(5.0),
                        Text(
                          "종료 날짜 : ${_tempRangeEnd == null?"-":"${_tempRangeEnd?.year}년 ${_tempRangeEnd?.month}월 ${_tempRangeEnd?.day}일"}",
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
                              }else if(diff_day! > 30){
                                return Util.toast(Strings.of(context)?.get("dateOver")??"Not Found");
                              }
                                _rangeStart.value = _tempRangeStart!;
                                _rangeEnd.value = _tempRangeEnd!;
                                Navigator.of(context).pop(false);
                                await getHistory();

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

  Future<void> getHistory() async {
    Logger logger = Logger();
    await pr?.show();
    _historyList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getHistory(
        controller.getUserInfo()?.authorization,
        Util.getDateCalToStr(_rangeStart.value,'yyyy-MM-dd'),
        Util.getDateCalToStr(_rangeEnd.value,'yyyy-MM-dd'),
        controller.getUserInfo()?.vehicId,
        receiptYn.value,
        taxYn.value,
        payType.value,
        payYn.value).then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d("getHistory() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["data"] != null) {
          var list = response.resultMap?["data"] as List;
          List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
          if(_historyList.isNotEmpty) _historyList.clear();
          _historyList.value?.addAll(itemsList);
        }else{
          _historyList.value = List.empty(growable: true);
        }
        setState(() {});
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getHistory() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getHistory() Error Default => ");
          break;
      }
    });
  }

  Widget itemListFuture() {
    final orderService = Provider.of<OrderService>(context);
    return FutureBuilder(
      future: orderService.getHistory(
          context,
          controller.getUserInfo()?.authorization,
          Util.getDateCalToStr(_rangeStart.value,'yyyy-MM-dd'),
          Util.getDateCalToStr(_rangeEnd.value,'yyyy-MM-dd'),
          controller.getUserInfo()?.vehicId,
          receiptYn.value,
          taxYn.value,
          payType.value,
          payYn.value
      ),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(_historyList.isNotEmpty) _historyList.clear();
            _historyList.value.addAll(snapshot.data);
          return getHistoryListWidget();
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

  Widget getListCardView(OrderModel item) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
            onTap: () async {
              Map<String,int> results = await Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailPage(item: item)));
              print("값을 볼까? => ${results["code"]}");
              if(results != null && results.containsKey("code")){
                if(results["code"] == 200) {
                  await getHistory();
                }
              }

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
                                        Util.ynToPay(item.payDate),
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            Util.getPayYnColor(item.payDate)) ,
                                      )),
                                  Container(
                                      padding: EdgeInsets.only(
                                          left: CustomStyle.getWidth(
                                              10.0),
                                          right: CustomStyle.getWidth(
                                              5.0)),
                                      child: Text(
                                        "${item.sellCustName}",
                                        style: CustomStyle.CustomFont(
                                            styleFontSize12,
                                            main_color),
                                      )),
                                  Text(
                                    "${item.sellDeptName}",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10, main_color),
                                  )
                                ])
                                )
                            ),
                            Util.ynToBoolean(item.payType)
                                ? Flexible(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.all(10.0),
                                  color: styleWhiteCol,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                    child: Text(
                                    "빠른지급",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12,
                                        order_state_09),
                                    )
                                  ),
                                ))
                                : const SizedBox()
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
                                  Util.makeString(item.sSido)??"Error",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, main_color,
                                      font_weight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  Util.makeString(item.sGungu)??"Error",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize16, main_color,
                                      font_weight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                CustomStyle.sizedBoxHeight(5.0),
                                Text(
                                  Util.makeString(item.sDong)??"Error",
                                  style: CustomStyle.CustomFont(
                                      styleFontSize12, main_color),
                                  textAlign: TextAlign.center,
                                ),
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
                                    Util.makeString(item.eSido)??"Error",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize16, main_color,
                                        font_weight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    Util.makeString(item.eGungu)??"Error",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize16, main_color,
                                        font_weight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  CustomStyle.sizedBoxHeight(5.0),
                                  Text(
                                    Util.makeString(item.eDong)??"Error",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12, main_color),
                                    textAlign: TextAlign.center,
                                  )
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
                                      "상차 ${Util.splitSDate(item.sDate)}",
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
                                        "하차 ${Util.splitEDate(item.eDate)}",
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
                            item.chargeType == "01" ? Expanded(
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
                            ):const SizedBox(),
                            Util.ynToBoolean(item.payType) == true? Expanded(
                              flex:1,
                              child: Text(
                                "빠른지급",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01),
                              )
                            ):const SizedBox(),
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
                                    item.receiptYn != "N" ?
                                        item.receiptDate != null ?
                                    "사진 (${Util.getDateStrToStr(item.receiptDate, "yy.MM.dd")})"
                                            : item.paperReceiptDate != null ? "실물 (${Util.getDateStrToStr(item.paperReceiptDate, "yy.MM.dd")})"
                                            : item.paperReceiptDate == null && item.receiptDate == null ? "-":"-"
                                            : "-",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12, text_color_01),
                                  )
                                )
                            ),
                            item.chargeType == "01" ? Expanded(
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
                                    item.taxinvYn != "N" ?
                                    item.taxinvYn == "R" ? "발행 대기"
                                        : "${item.taxinvYn == "Y" ? "전자":"일반"} (${Util.getDateStrToStr(item.taxinvDate, 'yy.MM.dd')})"
                                        : "-",
                                    textAlign: TextAlign.center,
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12, text_color_01),
                                  )
                                )
                            ): const SizedBox(),
                            Util.ynToBoolean(item.payType) == true? Expanded(
                                flex:1,
                                child: Text(
                                  Util.ynToBoolean(item.reqPayYN) == true ? "신청 (${Util.getDateStrToStr(item.reqPayDate, "yy.MM.dd")})" : "-",
                                  textAlign: TextAlign.center,
                                  style: CustomStyle.CustomFont(
                                      styleFontSize12, text_color_01),
                                )
                            ): const SizedBox(),
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

  Widget getHistoryListWidget() {
    return Expanded(
        child: _historyList.isNotEmpty
          ? SingleChildScrollView(
              child: Flex(
                  direction: Axis.vertical,
                  children: List.generate(
                    _historyList.length,
                    (index) {
                      var item = _historyList[index];
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

  Widget tabBarMenuWidget() {
      isSelected.value = List.empty(growable: true);
      isSelected.value = List.filled(4,false);
      return Container(
              height: CustomStyle.getHeight(60.0),
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  InkWell(
                      onTap: () async {
                        isSelected.value[0] = receiptYn == "Y"?false:true;
                        receiptYn.value = isSelected[0] == true ? "Y" :"";
                        await getHistory();
                      },
                      child: Container(
                          decoration: CustomStyle.customBoxDeco(styleWhiteCol,border_color: receiptYn.value == "Y" ? sub_color:text_color_03),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                          child: Text(
                            "인수증",
                            style: CustomStyle.CustomFont(styleFontSize12, receiptYn == "Y" ? sub_color:text_color_03),
                          )
                      )
                  ),
                  CustomStyle.sizedBoxWidth(5.0),
                  InkWell(
                      onTap: () async {
                        isSelected.value[1] = taxYn == "Y"?false:true;
                        taxYn.value = isSelected[1] == true ? "Y" :"";
                        await getHistory();
                      },
                      child: Container(
                          decoration: CustomStyle.customBoxDeco(styleWhiteCol,border_color: taxYn.value == "Y" ? sub_color:text_color_03),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                          child: Text(
                            "세금계산서",
                            style: CustomStyle.CustomFont(styleFontSize12, taxYn.value == "Y" ? sub_color:text_color_03),
                          )
                      )
                  ),
                  CustomStyle.sizedBoxWidth(5.0),
                  InkWell(
                      onTap: () async {
                        isSelected.value[2] = payType == "Y"?false:true;
                        payType.value = isSelected[2] == true ? "Y" :"";
                        await getHistory();
                      },
                      child: Container(
                          decoration: CustomStyle.customBoxDeco(styleWhiteCol,border_color: payType.value == "Y" ? sub_color:text_color_03),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                          child: Text(
                            "빠른지급",
                            style: CustomStyle.CustomFont(styleFontSize12, payType.value == "Y" ? sub_color:text_color_03),
                          )
                      )
                  ),
                  CustomStyle.sizedBoxWidth(5.0),
                  InkWell(
                      onTap: () async {
                        isSelected.value[3] = payYn == "Y"?false:true;
                        payYn.value = isSelected[3] == true ? "Y" :"";
                        await getHistory();
                      },
                      child: Container(
                          decoration: CustomStyle.customBoxDeco(styleWhiteCol,border_color: payYn.value == "Y" ? sub_color:text_color_03),
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(10.0)),
                          child: Text(
                            "입금",
                            style: CustomStyle.CustomFont(styleFontSize12, payYn.value == "Y" ? sub_color:text_color_03),
                          )
                      )
                  )
                ],
              )
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
              expandedHeaderPadding: EdgeInsets.zero,
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
                                      _rangeStart.value == null?"-":"${_rangeStart.value?.year}년 ${_rangeStart.value?.month}월 ${_rangeStart.value?.day}일",
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
                                      _rangeEnd.value == null?"-":"${_rangeEnd.value?.year}년 ${_rangeEnd.value?.month}월 ${_rangeEnd.value?.day}일",
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

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    Util.notificationDialog(context,"운송실적",webViewKey);
    return WillPopScope(
        onWillPop: () async {
          fbroad.FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
          return true;
        },
        child: Scaffold(
      backgroundColor: order_item_background,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
          child: AppBar(
            centerTitle: true,
            title: Text(
                Strings.of(context)?.get("history_title") ?? "Not Found",
                style: CustomStyle.appBarTitleFont(
                    styleFontSize16, styleWhiteCol)),
            leading: IconButton(
              onPressed: () {
                fbroad.FBroadcast.instance().broadcast(Const.INTENT_ORDER_REFRESH);
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
              tabBarMenuWidget(),
              itemListFuture()
            ]
        );
      })
      ),
    )
    );
  }

}
