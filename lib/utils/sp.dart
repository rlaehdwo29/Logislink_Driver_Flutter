import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/model/car_model.dart';
import 'package:logislink_driver_flutter/common/model/code_model.dart';
import 'package:logislink_driver_flutter/common/model/result_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/const.dart';

class SP extends GetxController {
  static SharedPreferences? m_Pref;

  @override
  void onInit() async {
    m_Pref ??= await SharedPreferences.getInstance();
    super.onInit();
  }

  static void open() async {
    m_Pref ??= await SharedPreferences.getInstance();
  }

  static void clear() {
    open();
    m_Pref?.clear();
  }

  static void remove(String key) {
    open();
    m_Pref?.remove(key);
    m_Pref?.commit();
  }

  static void putString(String key, String value) {
    open();
    m_Pref?.setString(key, value);
  }

  static void putInt(String key, int value) {
    open();
    m_Pref?.setInt(key, value);
  }

  static void putBool(String key, bool value) {
    open();
    m_Pref?.setBool(key, value);
  }

  static void putUserModel(String key, UserModel? value) {
    open();
    m_Pref?.setString(key,jsonEncode(value));
  }

  static String? get(String key) {
    open();
    return m_Pref?.getString(key);
  }

  static String? getString(String key, String defaultValue) {
    open();
    return m_Pref?.getString(key)??defaultValue;
  }

  static bool getBoolean(String key) {
    open();
    return m_Pref?.getBool(key)??false;
  }

  static bool? getDefaultTrueBoolean(String key) {
    open();
    return m_Pref?.getBool(key);
  }

  static int? getInt(String key,{int? defaultValue}) {
    open();
    defaultValue ??= 0;
    return m_Pref?.getInt(key)??defaultValue;
  }

  static String getFirstScreen(BuildContext context) {
    open();
    return m_Pref?.getString(Const.KEY_SETTING_SCREEN)??Const.first_screen[0];
  }

  static UserModel? getUserInfo(String key) {
    open();
    String? json = m_Pref?.getString(key);
    if(json == null){
      return null;
    }else {
      Map<String, dynamic> jsonData = jsonDecode(json);
      return UserModel.fromJSON(jsonData);
    }
  }

  static String getNavi() {
    open();
    return m_Pref?.getString(Const.KEY_SETTING_NAVI)??"카카오내비";
  }

  static void putStringList(String key, List<String>? list) {
    open();
    m_Pref?.setStringList(key, list??[]);
  }

  static List<String>? getStringList(String key) {
    open();
    List<String>? json = m_Pref?.getStringList(key);
    return json;
  }

/**
   * 공통코드 목록 저장
   */
  static void putCodeList(String key, String codeList) {
    open();
    Logger logger = Logger();
    try {
      m_Pref?.setString(key, codeList);
    }catch(e){
      logger.e(e);
    }
  }


  /**
   * 저장된 공통코드 목록 불러오기
   */
  static List<CodeModel>? getCodeList(String key) {
    Logger logger = Logger();
    List<CodeModel>? mList = List.empty(growable: true);
    open();
    if(m_Pref?.getString(key)?.isNotEmpty == true && m_Pref?.getString(key)?.isNull == false ) {
      String jsonString = m_Pref?.getString(key) ?? "";
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      var list = jsonData?["data"] as List;
      List<CodeModel>? itemsList = list.map((i) => CodeModel.fromJSON(i))
          .toList();
      mList.addAll(itemsList);
    }
    return mList;
  }

  /**
   * 저장된 공통코드 목록에서 코드네임 불러오기
   */
  static String getCodeName(String key, String val) {
    if (val.isEmpty) {
      return "";
    }
    List<CodeModel>? list = getCodeList(key);
    String codeName = "";
    for (CodeModel data in list!) {
      if (val == data.code) {
        codeName = data.codeName??"";
      }
    }
    return codeName;
  }

  static void setCar(CarModel? data) {
    open();
      m_Pref?.setString(Const.KEY_CAR_INFO, jsonEncode(data));
  }

  static CarModel? getCarInfo(String key) {
    open();
    String? json = m_Pref?.getString(key);
    if(json == null){
      return null;
    }else {
      Map<String, dynamic> jsonData = jsonDecode(json);
      return CarModel.fromJSON(jsonData);
    }
  }

}