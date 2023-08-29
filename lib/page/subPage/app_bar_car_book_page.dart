import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/car_book_model.dart';
import 'package:logislink_driver_flutter/common/model/car_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/main.dart';
import 'package:logislink_driver_flutter/page/subPage/car_book_reg_page.dart';
import 'package:logislink_driver_flutter/page/subPage/car_list_page.dart';
import 'package:logislink_driver_flutter/provider/appbar_service.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:dio/dio.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import 'car_reg_page.dart';

class AppBarCarBookPage extends StatefulWidget {
  AppBarCarBookPage({Key? key}):super(key: key);

  _AppBarCarBookPageState createState() => _AppBarCarBookPageState();
}

class _AppBarCarBookPageState extends State<AppBarCarBookPage> with TickerProviderStateMixin {
  final controller = Get.find<App>();

  final mCarBookList = List.empty(growable: true).obs;
  final mCarList = List.empty(growable: true).obs;
  final mCar = CarModel().obs;
  final focusDate = DateTime.now().obs;
  final startDate = DateTime(DateTime.now().year,DateTime.now().month,1).obs;
  final endDate = DateTime(DateTime.now().year,DateTime.now().month+1,0).obs;
  final mTabCode = "01".obs;
  late TabController _tabController;

  ProgressDialog? pr;

  final GlobalKey webViewKey = GlobalKey();
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;

  @override
  void initState() {
    super.initState();

    startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
    endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
    _tabController = TabController(
      length: 4,
      vsync: this,//vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
      initialIndex: 0
    );
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getTabApi(mTabCode.value);
      await getCar();
    });

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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> onCallback(bool? reload,String? code) async {
    if(reload == true){
      if(code?.isNotEmpty == true) {
        await getTabApi(code);
      }else{
        await getTabApi(mTabCode.value);
      }
      await getCar();
    }
  }

  Future<void> backMonth(String? code) async {
    focusDate.value = DateTime(focusDate.value.year,focusDate.value.month-1);
    startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
    endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
    await getTabApi(code);
  }

  Future<void> nextMonth(String? code) async {
    focusDate.value = DateTime(focusDate.value.year,focusDate.value.month+1);
    startDate.value = DateTime(focusDate.value.year,focusDate.value.month,1);
    endDate.value = DateTime(focusDate.value.year,focusDate.value.month+1,0);
    await getTabApi(code);
  }

  Future<void> _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      // 탭이 변경되는 중에만 호출됩니다.
      // _tabController.index를 통해 현재 선택된 탭의 인덱스를 가져올 수 있습니다.
      int selectedTabIndex = _tabController.index;
      switch(selectedTabIndex) {
        case 0 :
          mTabCode.value = "01";
          break;
        case 1 :
          mTabCode.value = "02";
          break;
        case 2 :
          mTabCode.value = "03";
          break;
        case 3 :
          mTabCode.value = "04";
          break;
      }
      await getTabApi(mTabCode.value);
    }
  }

  void goToCarList() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CarListPage(onCallback)));
  }

  void goToCarReg() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CarRegPage(null,onCallback)));
  }

  void goToCarEdit() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CarRegPage(mCar.value,onCallback)));
  }


  void goToCarBookReg() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CarBookRegPage(mTabCode.value,null,onCallback)));
  }

  Widget calendarWidget(String? code) {
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
                  onPressed: (){backMonth(code);},
                  icon: Icon(Icons.keyboard_arrow_left_outlined,size: 32,color: text_color_01)
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
                  onPressed: (){nextMonth(code);},
                  icon: Icon(Icons.keyboard_arrow_right_outlined,size: 32,color: text_color_01)
              )
          )
        ],
      ),
    );
  }

  Widget getTabFuture() {
    final appbarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
        future: appbarService.getTabList(
            controller.getUserInfo()?.authorization,
            controller.getCarInfo()?.carSeq,
            Util.getDateCalToStr(startDate.value, "yyyy-MM-dd"),
            Util.getDateCalToStr(endDate.value, "yyyy-MM-dd"),
            mTabCode.value
        ),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            mCarBookList.value = snapshot.data;
            return tabBarViewWidget();
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

  Future<void> getTabApi(String? tabValue) async {

    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getCarBook(
      controller.getUserInfo()?.authorization,
      controller.getCarInfo()?.carSeq,
        Util.getDateCalToStr(startDate.value, "yyyy-MM-dd"),
        Util.getDateCalToStr(endDate.value, "yyyy-MM-dd"),
        tabValue
    ).then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d("getTabApi() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["data"] != null) {
            var list = response.resultMap?["data"] as List;
            List<CarBookModel> itemsList = list.map((i) => CarBookModel.fromJSON(i)).toList();
            if(mCarBookList.isNotEmpty) mCarBookList.clear();
            mCarBookList.value?.addAll(itemsList);
        }else{
          mCarBookList.value = List.empty(growable: true);
        }
      }
      setState(() {});
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getTabApi() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getTabApi() Error Default => ");
          break;
      }
    });
  }

  Widget tabBarValueWidget(String? tabValue) {
    Widget _widget = oilWidget(tabValue);
    switch(tabValue) {
      case "01" :
        _widget = oilWidget(tabValue);
        break;
      case "02" :
        _widget = repairWidget(tabValue);
        break;
      case "03" :
        _widget = insuranceWidget(tabValue);
        break;
      case "04" :
        _widget = etcWidget(tabValue);
        break;
    }
    return _widget;
  }

  Widget oilWidget(String? code) {
    return Column(
      children: [
        calendarWidget(code),
        Container(
          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0),horizontal: CustomStyle.getWidth(20.0)),
            width: MediaQuery.of(context).size.width,
            color: main_color,
            child: Row(
              children : [
                Expanded(
                  flex: 1,
                  child: Text(
                    Strings.of(context)?.get("car_book_oil_value_04")??"Not Found",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                  )
                ),
                Expanded(
                    flex: 1,
                    child: Text(
                      Strings.of(context)?.get("car_book_oil_value_01")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                    )
                ),
                Expanded(
                    flex: 1,
                    child: Text(
                      Strings.of(context)?.get("car_book_oil_value_03")??"Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                    )
                )
              ]
            )
        ),
        Expanded(
            child: mCarBookList.isNotEmpty
                ? SingleChildScrollView(
                    child: Flex(
                        direction: Axis.vertical,
                        children: List.generate(
                          mCarBookList.length,
                          (index) {
                            var item = mCarBookList[index];
                            return InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CarBookRegPage(code,item,onCallback)));
                              },
                                child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(20.0)),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: line,
                                            width: CustomStyle.getWidth(1.0)
                                        )
                                    )
                                ),
                                child: Row(
                                children: [
                                  Expanded(
                                    flex:1,
                                      child: Text(
                                        "${item.bookDate}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                      )
                                  ),
                                  Expanded(
                                    flex:1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${Util.getInCodeCommaWon(item.price.toString())}원",
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                          ),
                                          Text(
                                            "(${Util.getInCodeCommaWon(item.refuelAmt.toString())}L)",
                                            textAlign: TextAlign.center,
                                            style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                          )
                                        ],
                                      )
                                  ),
                                  Expanded(
                                      flex:1,
                                      child: Text(
                                        "${Util.getInCodeCommaWon(item.mileage.toString())}${Strings.of(context)?.get("km")??"Not found"}",
                                        textAlign: TextAlign.center,
                                        style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                      )
                                  ),
                                ],
                              )
                                )
                            );
                          },
                        )))
                : SizedBox(
                    child: Center(
                        child: Text(
                      Strings.of(context)?.get("empty_list") ?? "Not Found",
                      style: CustomStyle.CustomFont(
                          styleFontSize20, styleBlackCol1),
                    )),
                  )
        )
      ],
    );
  }

  Widget repairWidget(String? code) {
    return Column(
      children: [
        calendarWidget(code),
        Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0),horizontal: CustomStyle.getWidth(20.0)),
            width: MediaQuery.of(context).size.width,
            color: main_color,
            child: Row(
                children : [
                  Expanded(
                      flex: 1,
                      child: Text(
                        Strings.of(context)?.get("car_book_repair_value_04")??"Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        Strings.of(context)?.get("car_book_repair_value_02")??"Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        Strings.of(context)?.get("car_book_repair_value_03")??"Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                      )
                  )
                ]
            )
        ),
        Expanded(
            child: mCarBookList.isNotEmpty
                ? SingleChildScrollView(
                child: Flex(
                    direction: Axis.vertical,
                    children: List.generate(
                      mCarBookList.length,
                          (index) {
                        var item = mCarBookList[index];
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CarBookRegPage(code,item,onCallback)));
                          },
                            child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(20.0)),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: line,
                                        width: CustomStyle.getWidth(1.0)
                                    )
                                )
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${item.bookDate}",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                    )
                                ),
                                Expanded(
                                    flex:1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${item.memo}",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                        ),
                                        Text(
                                          "${Util.getInCodeCommaWon(item.price.toString())}원",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                        )
                                      ],
                                    )
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${Util.getInCodeCommaWon(item.mileage.toString())}${Strings.of(context)?.get("km")??"Not found"}",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                    )
                                ),
                              ],
                            )
                          )
                        );
                      },
                    )))
                : SizedBox(
              child: Center(
                  child: Text(
                    Strings.of(context)?.get("empty_list") ?? "Not Found",
                    style: CustomStyle.CustomFont(
                        styleFontSize20, styleBlackCol1),
                  )),
            ))
      ],
    );
  }

  Widget insuranceWidget(String? code) {
    return Column(
      children: [
        calendarWidget(code),
        Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0),horizontal: CustomStyle.getWidth(20.0)),
            width: MediaQuery.of(context).size.width,
            color: main_color,
            child: Row(
                children : [
                  Expanded(
                      flex: 1,
                      child: Text(
                        Strings.of(context)?.get("car_book_insurance_value_03")??"Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        Strings.of(context)?.get("car_book_insurance_value_02")??"Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        Strings.of(context)?.get("car_book_insurance_value_01")??"Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                      )
                  )
                ]
            )
        ),
        Expanded(
            child: mCarBookList.isNotEmpty
                ? SingleChildScrollView(
                child: Flex(
                    direction: Axis.vertical,
                    children: List.generate(
                      mCarBookList.length,
                          (index) {
                        var item = mCarBookList[index];
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CarBookRegPage(code,item,onCallback)));
                          },
                            child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(20.0)),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                )
                              )
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${item.bookDate}",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                    )
                                ),
                                Expanded(
                                    flex:1,
                                        child: Text(
                                          "${item.memo}",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                        ),
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${Util.getInCodeCommaWon(item.price.toString())}${Strings.of(context)?.get("won")??"Not found"}",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                    )
                                ),
                              ],
                            )
                          )
                        );
                      },
                    )))
                : SizedBox(
              child: Center(
                  child: Text(
                    Strings.of(context)?.get("empty_list") ?? "Not Found",
                    style: CustomStyle.CustomFont(
                        styleFontSize20, styleBlackCol1),
                  )),
            ))
      ],
    );
  }

  Widget etcWidget(String? code) {
    return Column(
      children: [
        calendarWidget(code),
        Container(
            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(10.0),horizontal: CustomStyle.getWidth(20.0)),
            width: MediaQuery.of(context).size.width,
            color: main_color,
            child: Row(
                children : [
                  Expanded(
                      flex: 1,
                      child: Text(
                        Strings.of(context)?.get("car_book_etc_value_03")??"Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        Strings.of(context)?.get("car_book_etc_value_02")??"Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        Strings.of(context)?.get("car_book_etc_value_01")??"Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize13, styleWhiteCol),
                      )
                  )
                ]
            )
        ),
        Expanded(
            child: mCarBookList.isNotEmpty
                ? SingleChildScrollView(
                child: Flex(
                    direction: Axis.vertical,
                    children: List.generate(
                      mCarBookList.length,
                          (index) {
                        var item = mCarBookList[index];
                        return InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CarBookRegPage(code,item,onCallback)));
                            },
                            child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0),horizontal: CustomStyle.getWidth(20.0)),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: line,
                                        width: CustomStyle.getWidth(1.0)
                                    )
                                )
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${item.bookDate}",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                    )
                                ),
                                Expanded(
                                    flex:1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${item.memo}",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                        ),
                                        Text(
                                          "${Util.getInCodeCommaWon(item.price.toString())}원",
                                          textAlign: TextAlign.center,
                                          style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                        )
                                      ],
                                    )
                                ),
                                Expanded(
                                    flex:1,
                                    child: Text(
                                      "${Util.getInCodeCommaWon(item.mileage.toString())}${Strings.of(context)?.get("km")??"Not found"}",
                                      textAlign: TextAlign.center,
                                      style: CustomStyle.CustomFont(styleFontSize12, text_color_01),
                                    )
                                ),
                              ],
                            )
                          )
                        );
                      },
                    )))
                : SizedBox(
              child: Center(
                  child: Text(
                    Strings.of(context)?.get("empty_list") ?? "Not Found",
                    style: CustomStyle.CustomFont(
                        styleFontSize20, styleBlackCol1),
                  )),
            ))
      ],
    );
  }

  Widget tabBarViewWidget() {
    return Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            //주유 Tab
            tabBarValueWidget("01"),
            tabBarValueWidget("02"),
            tabBarValueWidget("03"),
            tabBarValueWidget("04"),
          ],
        )
    );
  }

  Future<void> getCar() async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).getCar(controller.getUserInfo()?.authorization).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCar() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          var list = _response.resultMap?["data"] as List;
          List<CarModel> itemsList = list.map((i) => CarModel.fromJSON(i)).toList();
          if(mCarList.value.isNotEmpty) mCarList.clear();
          mCarList.value?.addAll(itemsList);
          if(mCarList.isNotEmpty) {
            var count = 0;
            for (var carItem in mCarList.value) {
              if(carItem.mainYn == "Y") {
                count++;
                mCar.value = carItem;
              }
            }
            if(count == 0) {
              mCar.value = mCarList.value[0];
            }
            controller.setCar(mCar.value);
          }else{
            showCarReg();
          }
        }else{
          mCarList.value = List.empty(growable: true);
        }
        setState(() {});
      }else{
        openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getCar() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getCar() Error Default => ");
          break;
      }
    });
  }

  Widget customTabBarWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: text_color_01,
        child: TabBar(
          tabs: [
            Container(
              height: 80,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children : [
                  Icon(Icons.local_gas_station,size: 24,color: line),
                  CustomStyle.sizedBoxHeight(5.0),
                  Text(
                Strings.of(context)?.get("car_book_value_01")??"Not Found",
              ),
              ])
            ),
            Container(
              height: 80,
              alignment: Alignment.center,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children : [
                    Icon(Icons.garage,size: 24,color: line),
                    CustomStyle.sizedBoxHeight(5.0),
                    Text(
                      Strings.of(context)?.get("car_book_value_02")??"Not Found",
                    ),
                  ])
            ),
            Container(
              height: 80,
              alignment: Alignment.center,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children : [
                    Icon(Icons.fact_check_outlined,size: 24,color: line),
                    CustomStyle.sizedBoxHeight(5.0),
                    Text(
                      Strings.of(context)?.get("car_book_value_03")??"Not Found",
                    ),
                  ])
            ),
            Container(
              height: 80,
              alignment: Alignment.center,
              child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children : [
                    Icon(Icons.other_houses_outlined,size: 24,color: line),
                    CustomStyle.sizedBoxHeight(5.0),
                    Text(
                      Strings.of(context)?.get("car_book_value_04")??"Not Found",
                    ),
                  ])
            ),
          ],
          indicator: BoxDecoration(
            color: text_color_02
          ),
          labelColor: Colors.white,
          unselectedLabelColor: text_color_03,
          controller: _tabController,
        ));
  }

  Widget carServiceFuture() {
    final appbarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
        future: appbarService.getCar(context, controller.getUserInfo()?.authorization),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            mCarList.value = snapshot.data;
            if(mCarList.isNotEmpty) {
              var count = 0;
              for (var carItem in mCarList.value) {
                if(carItem.mainYn == "Y") {
                  count++;
                  mCar.value = carItem;
                }
              }
              if(count == 0) {
                mCar.value = mCarList.value[0];
              }
              controller.setCar(mCar.value);
            }else{
              showCarReg();
            }
            return carServiceWidget();
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

  void showCarReg(){
    openCommonConfirmBox(
        context,
        Strings.of(context)?.get("car_reg_message")??"Not Found",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          carReg();
        });
  }

  Future<void> carReg() async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).carReg(
        controller.getUserInfo()?.authorization,
        controller.getUserInfo().driverName,
        controller.getUserInfo().carNum,
        "Y", 0).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("carReg() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          await getCar();
          Util.toast("${Strings.of(context)?.get("car_reg_title")}${Strings.of(context)?.get("reg_success")}");
        }else{
          Util.toast(_response.message);
        }
      }else{
        openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("carReg() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("carReg() Error Default => ");
          break;
      }
    });
  }

  Widget carServiceWidget() {
    return Column(
        children: [
          Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          mCarList.isEmpty ?
          InkWell(
            onTap: (){
              goToCarReg();
            },
            child: Text(
              "등록된 차량이 없습니다.",
              style: CustomStyle.CustomFont(styleFontSize16, main_color,font_weight: FontWeight.w600),
            )
          ) :
              InkWell(
                onTap: (){
                  goToCarEdit();
                },
                child: Row(
                  children: [
                    Text(
                        mCar.value.carName??"",
                      style: CustomStyle.CustomFont(styleFontSize16, main_color,font_weight: FontWeight.w600),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: CustomStyle.getWidth(5.0)),
                      child: Text(
                        mCar.value.carNum??"",
                        style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                      )
                    )
                  ],
                ),
              ),
          Row(
          children : [
          IconButton(
              onPressed: (){
                goToCarReg();
              },
              icon: const Icon(Icons.add_circle_outline,size: 28,color: Colors.black)
          ),
          IconButton(
              onPressed: (){
                goToCarList();
              },
              icon: const Icon(Icons.menu,size: 28,color: Colors.black)
          )
          ])
        ],
      )
    ),
    customTabBarWidget(),
    getTabFuture()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    Util.notificationDialog(context,"차계부",webViewKey);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(60.0)),
          child: AppBar(
              centerTitle: true,
              title: Text(
                  Strings.of(context)?.get("car_book_title")??"Not Found",
                  style: CustomStyle.appBarTitleFont(styleFontSize18,styleWhiteCol)
              ),
              leading: IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                color: styleWhiteCol,
                icon: Icon(Icons.close,size: 28,color: styleWhiteCol),
              )
          )
      ),
      body: Obx((){
        return SafeArea(
            child: carServiceFuture(),
        );
      }),
        bottomNavigationBar: InkWell(
          onTap: () async {
            goToCarBookReg();
          },
          child: Container(
            height: 60.0,
            color: main_color,
            padding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children : [
                Container(
                  padding: EdgeInsets.only(right: CustomStyle.getWidth(5.0)),
                  child: const Icon(Icons.add_circle_outline,size: 24,color: Colors.white)
                ),
                Text(
                Strings.of(context)?.get("car_book_reg_btn") ?? "Not Found",
                textAlign: TextAlign.center,
                style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
              ),
            ])
          ),
        )
    );
  }

}