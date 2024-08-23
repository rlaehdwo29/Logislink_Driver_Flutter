import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/car_book_model.dart';
import 'package:logislink_driver_flutter/common/model/car_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

class CarBookRegPage extends StatefulWidget {
  String? mCode;
  CarBookModel? mData;
  final void Function(bool?,String?) onCallback;

  CarBookRegPage(this.mCode,this.mData,this.onCallback, {Key? key}):super(key: key);

  _CarBookRegPageState createState() => _CarBookRegPageState();
}

class _CarBookRegPageState extends State<CarBookRegPage>{
  final controller = Get.find<App>();

  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final mData = CarBookModel().obs;
  final _selectDay = "".obs;
  CarModel mCar = CarModel();

  String? regTitle;
  String? editTitle;
  bool regYn = false;
  String? main_title = "";
  ProgressDialog? pr;

  late TextEditingController priceController;
  late TextEditingController oilUnitPriceController;
  late TextEditingController memoController ;
  late TextEditingController mileageController;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      mCar = await controller.getCarInfo();
    });
    priceController = TextEditingController();
    oilUnitPriceController = TextEditingController();
    memoController = TextEditingController();
    mileageController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    priceController.dispose();
    oilUnitPriceController.dispose();
    memoController.dispose();
    mileageController.dispose();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    initView();
  }

  void initView() {
    switch(widget.mCode) {
      case "01" :
        regTitle = Strings.of(context)?.get("car_book_oil_reg_title")??"Not Found";
        editTitle = Strings.of(context)?.get("car_book_oil_edit_title")??"Not Found";
        break;
      case "02" :
        regTitle = Strings.of(context)?.get("car_book_repair_reg_title")??"Not Found";
        editTitle = Strings.of(context)?.get("car_book_repair_edit_title")??"Not Found";
        break;
      case "03" :
        regTitle = Strings.of(context)?.get("car_book_insurance_reg_title")??"Not Found";
        editTitle = Strings.of(context)?.get("car_book_insurance_edit_title")??"Not Found";
        break;
      case "04" :
        regTitle = Strings.of(context)?.get("car_book_etc_reg_title")??"Not Found";
        editTitle = Strings.of(context)?.get("car_book_etc_edit_title")??"Not Found";
        break;
    }

    if(widget.mData != null) {
      mData.value = CarBookModel(
        carSeq : widget.mData?.carSeq,
        driverId : widget.mData?.driverId,
        bookSeq : widget.mData?.bookSeq,
        itemCode : widget.mData?.itemCode,
        bookDate : widget.mData?.bookDate,
        price : widget.mData?.price,
        unit : widget.mData?.unit,
        total : widget.mData?.total,
        mileage : widget.mData?.mileage,
        fuel : widget.mData?.fuel,
        refuelAmt : widget.mData?.refuelAmt,
        unitPrice : widget.mData?.unitPrice,
        regDate : widget.mData?.regDate,
        memo : widget.mData?.memo,
      );
      regYn = false;
      main_title = editTitle;
    }else{
      mData.value = CarBookModel();
      regYn = true;
      main_title = regTitle;
    }
    _selectDay.value = mData.value.bookDate??"";

  }

  /**
   * Widget
   */

  // 기타 Widget
  Widget etcWidget() {
    priceController.text = (mData?.value.price == null ? "": mData?.value.price.toString())!;
    memoController.text = (mData?.value.memo == null ? "": mData?.value.memo.toString())!;
    mileageController.text = (mData?.value.mileage == null ? "" : mData?.value.mileage.toString())!;
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
                          Strings.of(context)?.get("car_book_etc_value_01")??"Not Found",
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
                              controller: priceController,
                              decoration: priceController.text.isNotEmpty
                                  ? InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              CustomStyle.getWidth(10.0)),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          priceController.clear();
                                          mData?.value.price = null;
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
                              onChanged: (etcPriceText) {
                                if (etcPriceText.isNotEmpty) {
                                  mData?.value.price = int.parse(etcPriceText);
                                  priceController.selection =
                                      TextSelection.collapsed(
                                          offset: priceController.text.length);
                                } else {
                                  mData?.value.price = null;
                                }
                              },
                            )),
                        Expanded(
                            flex: 2,
                            child: Text(
                                "원",
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            )
                        )
                      ]))
                ],
              )),
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
                          Strings.of(context)?.get("car_book_etc_value_02")??"Not Found",
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
                        controller: memoController,
                        decoration: memoController.text.isNotEmpty ?
                        InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              memoController.clear();
                              mData.value.memo = "";
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
                        onChanged: (memoPriceText) {
                          if (memoPriceText.isNotEmpty) {
                            mData.value.memo = memoPriceText;
                            memoController.selection = TextSelection.collapsed(offset: memoController.text.length);
                          } else {
                            mData.value.memo = "";
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
                          Strings.of(context)?.get("car_book_etc_value_03")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: Row(
                          children: [
                            Expanded(
                                flex:9,
                                child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textAlignVertical: TextAlignVertical.center,
                        controller: mileageController,
                        decoration: mileageController.text.isNotEmpty ?
                        InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              mileageController.clear();
                              mData.value.mileage = null;
                            },
                            icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                          ),
                        ) : InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.clear, size: 18,color: Colors.white),
                          ),
                        ),
                        onChanged: (mileageText) {
                          if (mileageText.isNotEmpty) {
                            mData.value.mileage = int.parse(mileageText);
                            mileageController.selection = TextSelection.collapsed(offset: mileageController.text.length);
                          } else {
                            mData.value.mileage = null;
                          }
                        },
                      )
                            ),
                            Expanded(
                                flex:2,
                                child: Text(
                                    "km",
                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                )
                            )
                      ]
                      )
                  )
                ],
              )
          ),
          // 4번째줄
          SizedBox(
              height: CustomStyle.getHeight(100.0),
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
                          Strings.of(context)?.get("car_book_etc_value_04")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: InkWell(
                          onTap: (){
                            openCalendarDialog();
                          },
                          child: Container(
                              height: CustomStyle.getHeight(100.0),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                              child: Text(
                                _selectDay.value.isEmpty ? "날짜를 선택하세요." : _selectDay.value,
                                style: CustomStyle.CustomFont(styleFontSize14, _selectDay.value.isEmpty?text_color_03:text_color_01),
                              )
                          )
                      )
                  )
                ],
              )
          )
        ],
      ),
    );
  }


  // 보험 Widget
  Widget insuranceWidget() {
    priceController.text = (mData?.value.price == null ? "" : mData?.value.price.toString())!;
    memoController.text = (mData?.value.memo == null ? "" : mData?.value.memo.toString())!;
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
                          Strings.of(context)?.get("car_book_insurance_value_01")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: Row(
                          children: [
                            Expanded(
                              flex:9,
                                child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        style: CustomStyle.CustomFont(styleFontSize14, Colors.black),
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textAlignVertical: TextAlignVertical.center,
                        controller: priceController,
                        decoration: priceController.text.isNotEmpty ?
                        InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              priceController.clear();
                              mData?.value.price = null;
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
                        onChanged: (repairPriceText) {
                          if (repairPriceText.isNotEmpty) {
                            mData?.value.price = int.parse(repairPriceText);
                            priceController.selection =  TextSelection.collapsed(offset: priceController.text.length);
                          } else {
                            mData?.value.price = null;
                          }
                        },
                      )),
                            Expanded(
                                child: Text(
                                  "원",
                                  style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                )
                            )
                      ])
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
                          Strings.of(context)?.get("car_book_insurance_value_02")??"Not Found",
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
                        controller: memoController,
                        decoration: memoController.text.isNotEmpty ?
                        InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              memoController.clear();
                              mData.value.memo = "";
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
                        onChanged: (memoPriceText) {
                          if (memoPriceText.isNotEmpty) {
                            mData.value.memo = memoPriceText;
                            memoController.selection = TextSelection.collapsed(offset: memoController.text.length);
                          } else {
                            mData.value.memo = "";
                          }
                        },
                      )
                  )
                ],
              )
          ),
          // 3번째줄
          SizedBox(
              height: CustomStyle.getHeight(100.0),
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
                          Strings.of(context)?.get("car_book_insurance_value_03")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: InkWell(
                          onTap: (){
                            openCalendarDialog();
                          },
                          child: Container(
                              height: CustomStyle.getHeight(100.0),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                              child: Text(
                                _selectDay.value.isEmpty ? "날짜를 선택하세요." : _selectDay.value,
                                style: CustomStyle.CustomFont(styleFontSize14, _selectDay.value.isEmpty?text_color_03:text_color_01),
                              )
                          )
                      )
                  )
                ],
              )
          )
        ],
      ),
    );
  }


  // 정비내역 Widget
  Widget repairWidget() {
    priceController.text = (mData?.value.price == null ? "" : mData?.value.price.toString())!;
    memoController.text = (mData?.value.memo == null ? "" : mData?.value.memo.toString())!;
    mileageController.text = (mData?.value.mileage == null ? "" : mData?.value.mileage.toString())!;
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
                          Strings.of(context)?.get("car_book_repair_value_01")??"Not Found",
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
                              controller: priceController,
                              decoration: priceController.text.isNotEmpty
                                  ? InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              CustomStyle.getWidth(10.0)),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          priceController.clear();
                                          mData?.value.price = null;
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
                              onChanged: (repairPriceText) {
                                if (repairPriceText.isNotEmpty) {
                                  mData?.value.price =
                                      int.parse(repairPriceText);
                                  priceController.selection =
                                      TextSelection.collapsed(
                                          offset: priceController.text.length);
                                } else {
                                  mData?.value.price = null;
                                }
                              },
                            )),
                        Expanded(
                            child: Text(
                          "원",
                          style: CustomStyle.CustomFont(
                              styleFontSize14, text_color_01),
                        ))
                      ]))
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
                          Strings.of(context)?.get("car_book_repair_value_02")??"Not Found",
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
                        controller: memoController,
                        decoration: memoController.text.isNotEmpty ?
                        InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              memoController.clear();
                              mData.value.memo = "";
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
                        onChanged: (memoPriceText) {
                          if (memoPriceText.isNotEmpty) {
                            mData.value.memo = memoPriceText;
                            memoController.selection = TextSelection.collapsed(offset: memoController.text.length);
                          } else {
                            mData.value.memo = "";
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
                          Strings.of(context)?.get("car_book_repair_value_03")??"Not Found",
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
                              controller: mileageController,
                              decoration: mileageController.text.isNotEmpty
                                  ? InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              CustomStyle.getWidth(10.0)),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          mileageController.clear();
                                          mData.value.mileage = null;
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
                              onChanged: (mileageText) {
                                if (mileageText.isNotEmpty) {
                                  mData.value.mileage = int.parse(mileageText);
                                  mileageController.selection =
                                      TextSelection.collapsed(
                                          offset:
                                              mileageController.text.length);
                                } else {
                                  mData.value.mileage = null;
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
          ),
          // 4번째줄
          SizedBox(
              height: CustomStyle.getHeight(100.0),
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
                          Strings.of(context)?.get("car_book_repair_value_04")??"Not Found",
                          textAlign: TextAlign.center,
                          style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                        ),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: InkWell(
                          onTap: (){
                            openCalendarDialog();
                          },
                          child: Container(
                              height: CustomStyle.getHeight(100.0),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                              child: Text(
                                _selectDay.value.isEmpty ? "날짜를 선택하세요." : _selectDay.value,
                                style: CustomStyle.CustomFont(styleFontSize14, _selectDay.value.isEmpty?text_color_03:text_color_01),
                              )
                          )
                      )
                  )
                ],
              )
          )
        ],
      ),
    );
  }

  // 주유 Widget
  Widget oilWidget() {
    priceController.text = (mData?.value.price == null ? "": mData?.value.price.toString())!;
    oilUnitPriceController.text = (mData?.value.unitPrice == null ? "" : mData?.value.unitPrice.toString())!;
    mileageController.text = (mData?.value.mileage == null ? "" : mData?.value.mileage.toString())!;
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
                        Strings.of(context)?.get("car_book_oil_value_01")??"Not Found",
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
                              controller: priceController,
                              decoration: priceController.text.isNotEmpty
                                  ? InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              CustomStyle.getWidth(10.0)),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          priceController.clear();
                                          mData?.value.price = null;
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
                              onChanged: (oilPriceText) {
                                if (oilPriceText.isNotEmpty) {
                                  mData?.value.price = int.parse(oilPriceText);
                                  priceController.selection =
                                      TextSelection.collapsed(
                                          offset: priceController.text.length);
                                } else {
                                  mData?.value.price = null;
                                }
                              },
                            )),
                        Expanded(
                            flex: 2,
                            child: Text(
                              "원",
                              style: CustomStyle.CustomFont(
                                  styleFontSize14, text_color_01),
                            ))
                      ]))
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
                              Strings.of(context)?.get("car_book_oil_value_02")??"Not Found",
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
                              controller: oilUnitPriceController,
                              decoration: oilUnitPriceController.text.isNotEmpty
                                  ? InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              CustomStyle.getWidth(10.0)),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          oilUnitPriceController.clear();
                                          mData.value.unitPrice = null;
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
                              onChanged: (oilUnitPriceText) {
                                if (oilUnitPriceText.isNotEmpty) {
                                  mData.value.unitPrice =
                                      int.parse(oilUnitPriceText);
                                  mData.value.refuelAmt = (mData.value.price! /
                                          mData.value.unitPrice!)
                                      .toInt();
                                  oilUnitPriceController.selection =
                                      TextSelection.collapsed(
                                          offset: oilUnitPriceController
                                              .text.length);
                                } else {
                                  mData.value.unitPrice = null;
                                  mData.value.refuelAmt = 0;
                                }
                              },
                            )),
                        Expanded(
                          flex: 2,
                            child: Text(
                          "원",
                          style: CustomStyle.CustomFont(
                              styleFontSize14, text_color_01),
                        ))
                      ]))
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
                              Strings.of(context)?.get("car_book_oil_value_03")??"Not Found",
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
                              controller: mileageController,
                              decoration: mileageController.text.isNotEmpty
                                  ? InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              CustomStyle.getWidth(10.0)),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          mileageController.clear();
                                          mData.value.mileage = null;
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
                              onChanged: (mileageText) {
                                if (mileageText.isNotEmpty) {
                                  mData.value.mileage = int.parse(mileageText);
                                  mileageController.selection =
                                      TextSelection.collapsed(
                                          offset:
                                              mileageController.text.length);
                                } else {
                                  mData.value.mileage = null;
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
              ),
              // 4번째줄
              SizedBox(
                  height: CustomStyle.getHeight(100.0),
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
                              Strings.of(context)?.get("car_book_oil_value_04")??"Not Found",
                              textAlign: TextAlign.center,
                              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                            ),
                          )
                      ),
                      Expanded(
                          flex: 6,
                          child: InkWell(
                            onTap: (){
                              openCalendarDialog();
                            },
                            child: Container(
                              height: CustomStyle.getHeight(100.0),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                child: Text(
                                  _selectDay.value.isEmpty ? "날짜를 선택하세요." : _selectDay.value,
                                style: CustomStyle.CustomFont(styleFontSize14, _selectDay.value.isEmpty?text_color_03:text_color_01),
                              )
                            )
                          )
                      )
                    ],
                  )
              )
            ],
          ),
    );
  }

  /**
   * 공통 모듈
   */

  // 날짜 Picker
  Future openCalendarDialog() {
    _focusedDay = DateTime.now();
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
                                  locale: 'ko_KR',
                                  rowHeight: MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio > 1500 ? CustomStyle.getHeight(30.h) :CustomStyle.getHeight(45.h) ,
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
                                            _selectDay.value = Util.getDateCalToStr(_tempSelectedDay, "yyyy-MM-dd");
                                            mData.value.bookDate = Util.getDateCalToStr(_tempSelectedDay, "yyyy-MM-dd");
                                            Navigator.of(context).pop();
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

  // Code별  Widget
  Widget returnCodeWidget() {
    Widget? _widget;
    switch(widget.mCode) {
      case "01" :
        _widget = oilWidget();
        break;
      case "02" :
        _widget = repairWidget();
        break;
      case "03" :
        _widget = insuranceWidget();
        break;
      case "04" :
        _widget = etcWidget();
        break;
      default:
        _widget = oilWidget();
        break;
    }
    return _widget;
  }

  bool validate() {

    switch(widget.mCode) {
      case "01" :
        if(mData.value.price == null) {
          Util.toast("${Strings.of(context)?.get("car_book_oil_value_01") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.unitPrice == null) {
          Util.toast("${Strings.of(context)?.get("car_book_oil_value_02") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.mileage == null) {
          Util.toast("${Strings.of(context)?.get("car_book_oil_value_03") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.bookDate == null) {
          Util.toast("${Strings.of(context)?.get("car_book_oil_value_04") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
          break;

      case "02" :
        if(mData.value.price == null) {
          Util.toast("${Strings.of(context)?.get("car_book_repair_value_01") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.memo == null) {
          Util.toast("${Strings.of(context)?.get("car_book_repair_value_02") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.mileage == null) {
          Util.toast("${Strings.of(context)?.get("car_book_repair_value_03") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.bookDate == null) {
          Util.toast("${Strings.of(context)?.get("car_book_repair_value_04") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        break;

      case "03" :
        if(mData.value.price == null) {
          Util.toast("${Strings.of(context)?.get("car_book_insurance_value_01") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.memo == null) {
          Util.toast("${Strings.of(context)?.get("car_book_insurance_value_02") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.bookDate == null) {
          Util.toast("${Strings.of(context)?.get("car_book_insurance_value_03") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        break;

      case "04" :
        if(mData.value.price == null) {
          Util.toast("${Strings.of(context)?.get("car_book_etc_value_01") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.memo == null) {
          Util.toast("${Strings.of(context)?.get("car_book_etc_value_02") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.mileage == null) {
          Util.toast("${Strings.of(context)?.get("car_book_oil_value_03") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        if(mData.value.bookDate == null) {
          Util.toast("${Strings.of(context)?.get("car_book_etc_value_04") ?? "Not Found"}${Strings.of(context)?.get("valid_fail") ?? "Not Found"}");
          return false;
        }
        break;
        }
        return true;
  }


  /**
   * Function
   */

  // 주유 Tab Function()
  void dialogCarBookDel() {
    openCommonConfirmBox(
        context,
        "${Strings.of(context)?.get("car_book_del_message")??"Not Found"}",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () {Navigator.of(context).pop(false);},
            () {
          Navigator.of(context).pop(false);
          carBookDel();
        }
    );
  }

  Future<void> carBookDel() async {
      Logger logger = Logger();
      var app = await controller.getUserInfo();
      await pr?.show();
      await DioService.dioClient(header: true).carBookDel(
          app.authorization,mData.value.bookSeq
      ).then((it) async {
        await pr?.hide();
        ReturnMap response = DioService.dioResponse(it);
        logger.d(
            "carBookDel() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
          Util.toast(Strings.of(context)?.get("delete_message")??"Not Found");
          Navigator.of(context).pop(false);
          widget.onCallback(true,widget.mCode);
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
                "carBookDel() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("carBookDel() Error Default => ");
            break;
        }
      });
  }


  Future<void> carUpdate() async {
    if (validate()) {
      Logger logger = Logger();
      var app = await controller.getUserInfo();
      await pr?.show();
      await DioService.dioClient(header: true).carEdit(
          app.authorization,
        mCar?.carSeq,
        mCar?.carName,
        mCar?.carNum,
        mCar?.mainYn,
        mData.value.mileage
      ).then((it) async {
        await pr?.hide();
        ReturnMap response = DioService.dioResponse(it);
        logger.d(
            "carUpdate() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
            Util.toast("$regTitle${Strings.of(context)?.get("reg_success")??"Not Found"}");
            Navigator.of(context).pop(false);
            widget.onCallback(true,widget.mCode);
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
                "carUpdate() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("carUpdate() Error Default => ");
            break;
        }
      });
    }
  }

  Future<void> carBookReg() async {
    if (validate()) {
      Logger logger = Logger();
      var app = await controller.getUserInfo();
      var app_car = await controller.getCarInfo();
      await pr?.show();
      await DioService.dioClient(header: true).carBookReg(
          app.authorization,
          app_car.carSeq,
        widget.mCode,
        mData.value.bookDate,
        mData.value.price,
        mData.value.mileage,
        mData.value.refuelAmt,
        mData.value.unitPrice,
        mData.value.memo ?? ""
      ).then((it) async {
        await pr?.hide();
        ReturnMap response = DioService.dioResponse(it);
        logger.d("carBookReg() _response -> ${response.status} // ${response.resultMap}");
          if (response.status == "200") {
              int accMileage = mCar.accMileage??0;
              int mileage = mData.value.mileage??0;
              if(accMileage < mileage) {
                carUpdate();
              } else {
                Util.toast(
                    "$regTitle${Strings.of(context)?.get("reg_success") ??
                        "Not Found"}");
                Navigator.of(context).pop(false);
                widget.onCallback(true, widget.mCode);
              }
            setState(() {});
          } else {
            Util.toast("${response.message}");
          }
      }).catchError((Object obj) async {
        await pr?.hide();
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print(
                "carBookReg() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("carBookReg() Error Default => ");
            break;
        }
      });
    }
  }

  Future<void> carBookEdit() async {
    if (validate()) {
      Logger logger = Logger();
      var app = await controller.getUserInfo();
      await pr?.show();
      await DioService.dioClient(header: true).carBookEdit(
        app.authorization,
        mData.value.bookSeq,
        widget.mCode,
        mData.value.bookDate,
        mData.value.price,
        mData.value.mileage,
        mData.value.refuelAmt,
        mData.value.unitPrice,
        mData.value.memo == null?"":mData.value.memo,
      ).then((it) async {
        await pr?.hide();
        ReturnMap response = DioService.dioResponse(it);
        logger.d("carBookEdit() _response -> ${response.status} // ${response.resultMap}");
        if (response.status == "200") {
            if(mCar!.accMileage! < mData.value.mileage!) {
              carUpdate();
            }else{
              Util.toast("$regTitle${Strings.of(context)?.get("reg_success")??"Not Found"}");
              Navigator.of(context).pop(false);
              widget.onCallback(true,widget.mCode);
            }
            setState(() {});
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
                "carBookEdit() Error => ${res?.statusCode} // ${res?.statusMessage}");
            break;
          default:
            print("carBookEdit() Error Default => ");
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);

    return Scaffold(
        backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(60.0)),
          child: AppBar(
              centerTitle: true,
              title: Text(
                  "$main_title",
                  style: CustomStyle.appBarTitleFont(styleFontSize18,styleWhiteCol)
              ),
              leading: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                color: styleWhiteCol,
                icon: Icon(Icons.keyboard_arrow_left_outlined,size: 32.w,color: styleWhiteCol),
              )
          )
      ),
      body: Obx(() {
          return SafeArea(
            child: SingleChildScrollView(
                child: returnCodeWidget()
            )
          );
        }),
        bottomNavigationBar: Row(
        children :[
          regYn ? Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                await carBookReg();
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
                  dialogCarBookDel();
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
                  carBookEdit();
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
    );
  }
  
}