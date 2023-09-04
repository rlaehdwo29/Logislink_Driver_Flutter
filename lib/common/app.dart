import 'package:get/get.dart';
import 'package:logislink_driver_flutter/common/model/bank_info_model.dart';
import 'package:logislink_driver_flutter/common/model/car_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/db/appdatabase.dart';
import 'package:logislink_driver_flutter/interfaces/rest.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:sqflite/sqflite.dart';

class App extends GetxController{

  // 타임아웃
  static final int CONNECT_TIMEOUT = 15;
  static final int WRITE_TIMEOUT = 15;
  static final int READ_TIMEOUT = 15;
  static Rest? mRest;
  static Rest? jusoRest;
  static Rest? kakaoRest;

  bool isBackgroundCheck = true;
  final device_info = <String, dynamic>{}.obs;
  final app_info = <String,dynamic>{}.obs;
  //BankInfoModel bank_info = BankInfoModel();
  final user = UserModel().obs;
  final car = CarModel().obs;
  final isIsNoticeOpen = false.obs;

  /*void setBankInfo(BankInfoModel? bankInfo) {
    bank_info = bankInfo!;
  }

  BankInfoModel? getBankInfo() {
    return bank_info;
  }*/


  void setUserInfo(UserModel userInfo) {
    SP.putUserModel(Const.KEY_USER_INFO, userInfo);
    user.value = userInfo;
    update();
  }


   UserModel getUserInfo() {
    if (user == null) {
      user.value = UserModel();
    }else{
      user.value = SP.getUserInfo(Const.KEY_USER_INFO)?? UserModel();
    }

    return user.value;
  }

  void setCar(CarModel carInfo) {
    SP.setCar(carInfo);
    car.value = carInfo;
    update();
  }

  CarModel getCarInfo() {
    if (car == null) {
      car.value = CarModel();
    } else {
      car.value = SP.getCarInfo(Const.KEY_CAR_INFO) ?? CarModel();
    }
    return car.value;
  }

  AppDataBase getRepository() {
    var db = AppDataBase();
    return db;
}

}