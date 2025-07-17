import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/car_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';

class CarRegPage extends StatefulWidget {
  CarModel? mCar;
  final void Function(bool?,String?) onCallback;

  CarRegPage(this.mCar, this.onCallback, {Key? key}):super(key: key);

  _CarRegPageState createState() => _CarRegPageState();
}

class _CarRegPageState extends State<CarRegPage> {
  final controller = Get.find<App>();
  final mCar = CarModel().obs;
  String? main_title = "";
  bool regYn = false;
  ProgressDialog? pr;

  late TextEditingController carNameController;
  late TextEditingController carNumController;
  late TextEditingController accMileageController ;

  @override
  void initState(){
    super.initState();
    carNameController = TextEditingController();
    carNumController = TextEditingController();
    accMileageController = TextEditingController();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    initView();
  }

  void initView() {
    if(widget.mCar != null) {
      mCar.value = CarModel(
        carSeq : widget.mCar?.carSeq,
        driverId : widget.mCar?.driverId,
        carName : widget.mCar?.carName,
        carNum : widget.mCar?.carNum,
        mainYn : widget.mCar?.mainYn,
        regDate : widget.mCar?.regDate,
        useYn : widget.mCar?.useYn,
        accMileage : widget.mCar?.accMileage
      );
      regYn = false;
    }else{
      mCar.value = CarModel();
      regYn = true;
    }
  }

  @override
  void dispose(){
    super.dispose();
    carNameController.dispose();
    carNumController.dispose();
    accMileageController.dispose();
  }

  bool validate() {
   if(mCar.value.carName?.isEmpty == true) {
     Util.toast("${Strings.of(context)?.get("car_reg_value_01")??"Not Found"}${Strings.of(context)?.get("valid_fail")??"Not Found"}");
     return false;
   }
   if(mCar.value.carNum?.isEmpty == true) {
     Util.toast("${Strings.of(context)?.get("car_reg_value_02")??"Not Found"}${Strings.of(context)?.get("valid_fail")??"Not Found"}");
     return false;
   }
   if(mCar.value.accMileage == null) {
     Util.toast("${Strings.of(context)?.get("car_reg_value_03")??"Not Found"}${Strings.of(context)?.get("valid_fail")??"Not Found"}");
     return false;
   }
   return true;
  }

  Future<void> carReg() async {
    if (validate()) {
      Logger logger = Logger();
      var app = await controller.getUserInfo();
      await pr?.show();
      await DioService.dioClient(header: true).carReg(
          app.authorization,
          mCar?.value.carName,
          mCar?.value.carNum,
          "Y",
          mCar?.value.accMileage
      ).then((it) async {
        await pr?.hide();
        ReturnMap response = DioService.dioResponse(it);
        logger.d(
            "carReg() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
          Util.toast("${Strings.of(context)?.get("car_reg_title")??"Not Found"}${Strings.of(context)?.get("reg_success")??"Not Found"}");
          Navigator.of(context).pop(false);
          widget.onCallback(true,"");
        }else{
          openOkBox(context,response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }).catchError((Object obj) async {
        await pr?.hide();
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
  }

  Future<void> carEdit() async {
    if (validate()) {
      Logger logger = Logger();
      var app = await controller.getUserInfo();
      await pr?.show();
      await DioService.dioClient(header: true).carEdit(
          app.authorization,
          mCar?.value.carSeq,
          mCar?.value.carName,
          mCar?.value.carNum,
          mCar?.value.mainYn,
          mCar?.value.accMileage
      ).then((it) async {
        await pr?.hide();
        ReturnMap response = DioService.dioResponse(it);
        logger.d(
            "carEdit() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
          Util.toast("${Strings.of(context)?.get("car_edit_title")??"Not Found"}${Strings.of(context)?.get("reg_success")??"Not Found"}");
          Navigator.of(context).pop(false);
          widget.onCallback(true,"");
        }else{
          openOkBox(context,response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }).catchError((Object obj) async {
        await pr?.hide();
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print("carEdit() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("carEdit() Error Default => ");
            break;
        }
      });
    }
  }

  void dialogCarDel() {
    openCommonConfirmBox(
        context,
        Strings.of(context)?.get("car_del_message")??"Not Found",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          carDel();
        });
  }

  Future<void> carDel() async {
    if (validate()) {
      Logger logger = Logger();
      var app = await controller.getUserInfo();
      await pr?.show();
      await DioService.dioClient(header: true).carDel(
          app.authorization,
          mCar?.value.carSeq,
          "N"
      ).then((it) async {
        await pr?.hide();
        ReturnMap response = DioService.dioResponse(it);
        logger.d(
            "carDel() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
          Util.toast("${Strings.of(context)?.get("delete_message")??"Not Found"}");
          Navigator.of(context).pop(false);
          widget.onCallback(true,"");
        }else{
          openOkBox(context,response.message??"",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
        }
      }).catchError((Object obj) async {
        await pr?.hide();
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print("carDel() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("carDel() Error Default => ");
            break;
        }
      });
    }
  }

  Widget bodyWidget() {
    carNameController.text = (mCar?.value.carName == null ? "" : mCar?.value.carName)!;
    carNumController.text = (mCar?.value.carNum == null ? "" : mCar?.value.carNum)!;
    accMileageController.text = (mCar?.value.accMileage == null ? "0" : mCar?.value.accMileage.toString())!;
    return Container(
      margin: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          border: Border.all(color: line,width:  CustomStyle.getWidth(1.0))
      ),
      child: Column(
        children: [
          // 1번째줄
          Container(
              height: CustomStyle.getHeight(100.0),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:BorderSide(
                          color: line,
                          width: CustomStyle.getWidth(1.0)
                      )
                  )
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        height: CustomStyle.getHeight(100.0),
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0),horizontal: CustomStyle.getWidth(10.0)),
                        decoration: BoxDecoration(
                            border: Border(
                                right:BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("car_reg_value_01")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textAlignVertical: TextAlignVertical.center,
                        controller: carNameController,
                        decoration: carNameController.text.isNotEmpty ?
                        InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              carNameController.clear();
                              mCar?.value.carName = "";
                            },
                            icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                          ),
                        ) : InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.clear, size: 18,color: Colors.white,),
                          ),
                        ),
                        onChanged: (carNameText) {
                          if (carNameText.isNotEmpty) {
                            mCar?.value.carName = carNameText;
                            carNameController.selection =  TextSelection.collapsed(offset: carNameController.text.length);
                          } else {
                            mCar?.value.carName = "";
                          }
                        },
                      )
                  )
                ],
              )
          ),
          // 2번째줄
          Container(
              height: CustomStyle.getHeight(100.0),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:BorderSide(
                          color: line,
                          width: CustomStyle.getWidth(1.0)
                      )
                  )
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        height: CustomStyle.getHeight(100.0),
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0),horizontal: CustomStyle.getWidth(10.0)),
                        decoration: BoxDecoration(
                            border: Border(
                                right:BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("car_reg_value_02")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textAlignVertical: TextAlignVertical.center,
                        controller: carNumController,
                        decoration: carNumController.text.isNotEmpty ?
                        InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              carNumController.clear();
                              mCar.value.carNum = "";
                            },
                            icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                          ),
                        ) : InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.clear, size: 18,color: Colors.white,),
                          ),
                        ),
                        onChanged: (carNumText) {
                          if (carNumText.isNotEmpty) {
                            mCar.value.carNum = carNumText;
                            carNumController.selection = TextSelection.collapsed(offset: carNumController.text.length);
                          } else {
                            mCar.value.carNum = "";
                          }
                        },
                      )
                  )
                ],
              )
          ),
          // 3번째줄
          Container(
              height: CustomStyle.getHeight(100.0),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:BorderSide(
                          color: line,
                          width: CustomStyle.getWidth(1.0)
                      )
                  )
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        height: CustomStyle.getHeight(100.0),
                        padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(15.0),horizontal: CustomStyle.getWidth(10.0)),
                        decoration: BoxDecoration(
                            border: Border(
                                right:BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                )
                            )
                        ),
                        child: Text(
                          Strings.of(context)?.get("car_reg_value_03")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: Row(children: [
                        Expanded(
                            flex: 10,
                            child: TextField(
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              style: CustomStyle.CustomFont(
                                  styleFontSize14, Colors.black),
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              textAlignVertical: TextAlignVertical.center,
                              controller: accMileageController,
                              decoration: accMileageController.text.isNotEmpty
                                  ? InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              CustomStyle.getWidth(10.0)),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          accMileageController.clear();
                                          mCar.value.accMileage = 0;
                                        },
                                        icon: const Icon(
                                          Icons.clear,
                                          size: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  : InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              CustomStyle.getWidth(10.0)),
                                      suffixIcon: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.clear,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                              onChanged: (accMileageText) {
                                if (accMileageText.isNotEmpty) {
                                  mCar.value.accMileage =
                                      int.parse(accMileageText);
                                  accMileageController.selection =
                                      TextSelection.collapsed(
                                          offset:
                                              accMileageController.text.length);
                                } else {
                                  mCar.value.accMileage = 0;
                                }
                              },
                            )),
                        Expanded(
                          flex: 2,
                            child: Text(
                          "km",
                          style: CustomStyle.CustomFont(
                              styleFontSize14, text_color_01),
                        ))
                      ]))
                ],
              )
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);

    return SafeArea(
        child: Scaffold(
        backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(60.0)),
          child: AppBar(
              centerTitle: true,
              title: Text(
                  "${regYn ? Strings.of(context)?.get("car_reg_title")??"Not Found" : Strings.of(context)?.get("car_edit_title")??"Not Found"}",
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
      body:Obx(() {
      return  SingleChildScrollView(
            child: bodyWidget()
        );
      }),
        bottomNavigationBar: Row(
            children :[
              regYn ? Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () async {
                      carReg();
                    },
                    child: Container(
                      height: 60.0,
                      color: main_color,
                      padding:
                      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                      child: Text(
                        Strings.of(context)?.get("reg_btn") ?? "Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                      ),
                    ),
                  )
              ):const SizedBox(),
              !regYn ? Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () async {
                      dialogCarDel();
                    },
                    child: Container(
                      height: 60.0,
                      color: cancel_btn,
                      padding:
                      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                      child: Text(
                        Strings.of(context)?.get("delete_btn") ?? "Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                      ),
                    ),
                  )
              ) : const SizedBox(),
              !regYn ? Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () async {
                      carEdit();
                    },
                    child: Container(
                      height: 60.0,
                      color: main_color,
                      padding:
                      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                      child: Text(
                        Strings.of(context)?.get("edit_btn") ?? "Not Found",
                        textAlign: TextAlign.center,
                        style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                      ),
                    ),
                  )
              ) : const SizedBox()
            ])
    ));
  }
}