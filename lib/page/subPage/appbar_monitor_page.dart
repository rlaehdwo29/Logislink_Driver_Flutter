import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/model/monitor_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/main.dart';
import 'package:logislink_driver_flutter/provider/appbar_service.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class AppBarMonitorPage extends StatefulWidget {
  AppBarMonitorPage({Key? key}):super(key: key);

  _AppBarMonitorPageState createState() => _AppBarMonitorPageState();
}

class _AppBarMonitorPageState extends State<AppBarMonitorPage> {
  ProgressDialog? pr;
  final controller = Get.find<App>();
  final mModel = MonitorModel().obs;
  final focusDate = DateTime.now().obs;
  final startDate = DateTime(DateTime.now().year,DateTime.now().month,1).obs;
  final endDate = DateTime(DateTime.now().year,DateTime.now().month+1,0).obs;

  final GlobalKey webViewKey = GlobalKey();
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;

  @override
  void initState(){
    super.initState();
    startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
    endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);

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

  void backMonth() {
    focusDate.value = DateTime(focusDate.value.year,focusDate.value.month-1);
    startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
    endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
  }

  void nextMonth() {
    focusDate.value = DateTime(focusDate.value.year,focusDate.value.month+1);
    startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
    endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
  }

  Widget itemListFuture() {
    final appbarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
        future: appbarService.getMonitor(
            context,
            Util.getDateCalToStr(startDate.value, "yyyy-MM-dd"),
            Util.getDateCalToStr(endDate.value, "yyyy-MM-dd")),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            mModel.value = snapshot.data;
            return bodyWidget();
          }else if(snapshot.hasError) {
            return  Container(
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
        }
    );
  }

  Widget bodyWidget() {
    return Column(
      children: [
        // Tap 1번째줄
        Container(
          width: MediaQuery.of(context).size.width,
          color: main_color,
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child:Text(
                    Strings.of(context)?.get("monitor_order_value_01")??"Not Found",
                  textAlign: TextAlign.center,
                  style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol),
                )
              ),
              Expanded(
                  flex: 1,
                  child:Text(
                    Strings.of(context)?.get("monitor_order_value_02")??"Not Found",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol),
                  )
              ),
              Expanded(
                  flex: 1,
                  child:Text(
                    Strings.of(context)?.get("monitor_order_value_03")??"Not Found",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol),
                  )
              )
            ],
          )
        ),
        // Tab 1번째줄 내용
        Container(
            width: MediaQuery.of(context).size.width,
            color: styleWhiteCol,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
            child: Column(
              children: [
                // 소계 컬럼
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child:Text(
                          Strings.of(context)?.get("monitor_order_item_value_01_01")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child:Text(
                          Util.getInCodeCommaWon(mModel.value.allCnt),
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child:Text(
                         "-",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                        )
                    )
                  ],
                ),
                CustomStyle.getDivider1(),
                // 일반 컬럼
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                            child: Text(
                            Strings.of(context)?.get("monitor_order_item_value_01_02")??"Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                          )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                            child: Text(
                            Util.getInCodeCommaWon(mModel.value.normalCnt),
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                          )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                            child: Text(
                            "-",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                          )
                        )
                    )
                  ],
                ),
                CustomStyle.getDivider1(),
                // 빠른지급신청 컬럼
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child:Text(
                          Strings.of(context)?.get("monitor_order_item_value_01_03")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child:Text(
                          Util.getInCodeCommaWon(mModel.value.quickCnt),
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child:Text(
                          "-",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                        )
                    )
                  ],
                )
            ])
        ),

        // Tap 2번째줄
        Container(
            width: MediaQuery.of(context).size.width,
            color: main_color,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 1,
                    child:Text(
                      Strings.of(context)?.get("monitor_order_value_04")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol),
                    )
                ),
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                        children :[
                            Text(
                            Strings.of(context)?.get("monitor_order_value_02")??"Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol),
                          ),
                          Text(
                            Strings.of(context)?.get("monitor_order_value_unit_01")??"Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize11, styleWhiteCol),
                          ),
                        ]),
                        Text(
                          Strings.of(context)?.get("monitor_order_value_unit_02")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize11, styleWhiteCol),
                        ),
                  ])
                ),
                Expanded(
                    flex: 1,
                    child:Text(
                      Strings.of(context)?.get("monitor_order_value_03")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize14, styleWhiteCol),
                    )
                )
              ],
            )
        ),
        // Tab 2번째줄 내용
        Container(
            width: MediaQuery.of(context).size.width,
            color: styleWhiteCol,
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0)),
            child: Column(
                children: [
                  // 소계 컬럼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child:Text(
                            Strings.of(context)?.get("monitor_order_item_value_01_01")??"Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child:Text(
                            Util.getInCodeCommaWon(mModel.value.allCharge),
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child:Text(
                            "-",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                          )
                      )
                    ],
                  ),
                  CustomStyle.getDivider1(),
                  // 일반 컬럼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                              child: Text(
                                Strings.of(context)?.get("monitor_order_item_value_01_02")??"Not Found",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                              )
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                              child: Text(
                                Util.getInCodeCommaWon(mModel.value.normalCharge),
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                              )
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                              child: Text(
                                "-",
                                textAlign: TextAlign.center,
                                style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                              )
                          )
                      )
                    ],
                  ),
                  CustomStyle.getDivider1(),
                  // 빠른지급신청 컬럼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child:Text(
                            Strings.of(context)?.get("monitor_order_item_value_01_03")??"Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child:Text(
                            Util.getInCodeCommaWon(mModel.value.quickCharge),
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child:Text(
                            Strings.of(context)?.get("monitor_order_item_value_02_03_note")??"Not Found",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(styleFontSize13, text_color_01),
                          )
                      )
                    ],
                  )
                ])
        )
      ],
    );
  }

  Widget calendarWidget() {
    var mCal = Util.getDateCalToStr(focusDate.value, "yyyy-MM-dd");
    return Container(
      color: styleWhiteCol,
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: (){backMonth();},
              icon: Icon(Icons.keyboard_arrow_left_outlined,size: 32.w,color: text_color_01)
            )
          ),
          Expanded(
            flex: 1,
            child: Text(
                "${mCal.split("-")[0]}년 ${mCal.split("-")[1]}월",
                style: CustomStyle.CustomFont(styleFontSize14, Colors.black)
            )
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                  onPressed: (){nextMonth();},
                  icon: Icon(Icons.keyboard_arrow_right_outlined,size: 32.w,color: text_color_01)
            )
          )
        ],
      ),
    );
  }

  Widget topWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(20.0),horizontal: CustomStyle.getWidth(10.0)),
      color: cancel_btn,
      child: Text(
        Strings.of(context)?.get("monitor_value_01")??"Not Found",
        style: CustomStyle.CustomFont(styleFontSize16, styleWhiteCol),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    Util.notificationDialog(context,"실적현황",webViewKey);
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(60.0)),
          child: AppBar(
            centerTitle: true,
              title: Text(
                 Strings.of(context)?.get("monitor_title")??"Not Found",
                  style: CustomStyle.appBarTitleFont(styleFontSize18,styleWhiteCol)
              ),
              leading: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                color: styleWhiteCol,
                icon: Icon(Icons.close,size: 28,color: styleWhiteCol),
              )
            )
      ),
      body: Obx((){
         return SafeArea(
         child: Column(
           children: [
             topWidget(),
             calendarWidget(),
             itemListFuture()
           ],
         )
        );
      }),
    );
  }
  
}