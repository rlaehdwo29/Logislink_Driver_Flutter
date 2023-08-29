import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/car_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/page/subPage/car_reg_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:dio/dio.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class CarListPage extends StatefulWidget {
  final void Function(bool?,String?) onCallback;

  CarListPage(this.onCallback, {Key? key}):super(key: key);

  _CarListPageState createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  final controller = Get.find<App>();
  final mList = List.empty(growable: true).obs;
  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();
    getCar();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> callback(bool? reload,String? code) async {
    if(reload == true){
      await getCar();
    }
  }

  Future<void> setMainCar(CarModel data) async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).carEdit(
        controller.getUserInfo()?.authorization,
        data.carSeq,
      data.carName,
      data.carNum,
        "Y",
      data.accMileage
    ).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("setMainCar() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        Util.toast("${Strings.of(context)?.get("car_select_message")??"Not Found"}");
        await getCar();
      }else{
        openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("setMainCar() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("setMainCar() Error Default => ");
          break;
      }
    });
}

  Future<void> getCar() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getCar(controller.getUserInfo()?.authorization).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCar() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          var list = _response.resultMap?["data"] as List;
          List<CarModel> itemsList = list.map((i) => CarModel.fromJSON(i)).toList();
          mList.value = itemsList;
          if(mList.isNotEmpty) {
            var count = 0;
            for(var data in mList){
              if(data.mainYn == "Y") {
                count++;
              }
            }
            if(count == 0) {
              setMainCar(mList[0]);
            }
          }
        }else{
          mList.value = List.empty(growable: true);
        }
        setState(() {});
      }else{
        openOkBox(context,_response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj) async {
      await pr?.hide();
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

  void onEditCar(CarModel item) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CarRegPage(item,callback)));
  }

  void dialogCarDel(CarModel item) {
    openCommonConfirmBox(
        context,
        Strings.of(context)?.get("car_del_message")??"Not Found",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          carDel(item);
        });
  }

  Future<void> carDel(CarModel mCar) async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).carDel(
        controller.getUserInfo()?.authorization,
        mCar?.carSeq,
        "N"
    ).then((it) async {
      await pr?.hide();
      ReturnMap response = DioService.dioResponse(it);
      logger.d("carDel() _response -> ${response.status} // ${response.resultMap}");
      if (response.status == "200") {
        Util.toast("${Strings.of(context)?.get("delete_message")??"Not Found"}");
        await getCar();
      }else{
        openOkBox(context,response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print(
              "carDel() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("carDel() Error Default => ");
          break;
      }
    });
  }

  Widget carListWidget() {
    return mList.isNotEmpty ?
        SingleChildScrollView(
          child:Flex(
              direction: Axis.vertical,
              children: List.generate(
                mList.length,
            (index) {
              var item = mList[index];
              return InkWell(
                onTap: (){
                  setMainCar(item);
                },
                child: Slidable(
                  key: const ValueKey(0),
                  endActionPane:  ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        // An action can be bigger than the others.
                        onPressed: (BuildContext context) => onEditCar(item),
                        backgroundColor: main_color,
                        foregroundColor: Colors.white,
                        icon: Icons.archive,
                        label: '수정하기',
                      ),
                      SlidableAction(
                        onPressed: (BuildContext context) => dialogCarDel(item),
                        backgroundColor: cancel_btn,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '삭제하기',
                      ),
                    ],
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: line, width: CustomStyle.getWidth(0.5)
                            )
                        )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            padding: EdgeInsets.only(
                                right: CustomStyle.getWidth(5.0)),
                            child: Text(
                              item.carName??"",
                              style: CustomStyle.CustomFont(
                                  styleFontSize16, main_color,
                                  font_weight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            item.carNum??"",
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_02),
                          ),
                        ]),
                        item.mainYn == "Y" ? Icon(Icons.check_sharp, size: 28,color: sub_color) : const SizedBox()
                      ],
                    ),
                  ),
                )
              );
            }
              )
          )
        ): SizedBox(
          child: Center(
              child: Text(
                Strings.of(context)?.get("empty_list") ?? "Not Found",
                style:
                CustomStyle.CustomFont(styleFontSize20, styleBlackCol1),
              )),
        );
  }

  void goToCarReg() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CarRegPage(null,callback)));
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          widget.onCallback(true, null);
          return false;
        } ,
      child: Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(60.0)),
          child: AppBar(
              centerTitle: true,
              title: Text(
                  "${Strings.of(context)?.get("car_list_title")??"Not Found"}",
                  style: CustomStyle.appBarTitleFont(styleFontSize18,styleWhiteCol)
              ),
              leading: IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                  widget.onCallback(true, null);
                },
                color: styleWhiteCol,
                icon: Icon(Icons.keyboard_arrow_left,size: 32,color: styleWhiteCol),
              )
          )
      ),
      body: Obx(() {
        return SafeArea(
            child: carListWidget()
        );
      }),
        bottomNavigationBar: InkWell(
          onTap: () async {
            goToCarReg();
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
                      Strings.of(context)?.get("car_reg_title") ?? "Not Found",
                      textAlign: TextAlign.center,
                      style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                    ),
                  ])
          ),
        )
      )
    );
  }
}
