import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/car_book_model.dart';
import 'package:logislink_driver_flutter/common/model/car_model.dart';
import 'package:logislink_driver_flutter/common/model/juso_model.dart';
import 'package:logislink_driver_flutter/common/model/monitor_model.dart';
import 'package:logislink_driver_flutter/common/model/notice_model.dart';
import 'package:logislink_driver_flutter/common/model/sales_manage_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:dio/dio.dart';
import 'package:logislink_driver_flutter/utils/util.dart';

class AppbarService with ChangeNotifier {
  final addrList = List.empty(growable: true).obs;
  final monitorModel = MonitorModel().obs;
  final regCarList = List.empty(growable: true).obs;    // 차계부 차량 리스트
  final tabCarList = List.empty(growable: true).obs;    // 차계부 탭별 리스트
  final salesList = List.empty(growable: true).obs;
  final noticeList = List.empty(growable: true).obs;

  AppbarService() {
    addrList.value = List.empty(growable: true);
    salesList.value = List.empty(growable: true);
    monitorModel.value = MonitorModel();
    regCarList.value = List.empty(growable: true);
    tabCarList.value = List.empty(growable: true);
    noticeList.value = List.empty(growable: true);
  }

  void init() {
    addrList.value = List.empty(growable: true);
    salesList.value = List.empty(growable: true);
    monitorModel.value = MonitorModel();
    regCarList.value = List.empty(growable: true);
    tabCarList.value = List.empty(growable: true);
    noticeList.value = List.empty(growable: true);
  }

  Future getNotice(BuildContext? context, String? auth) async {
    Logger logger = Logger();
    noticeList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getNotice(auth).then((it) {
      if (noticeList.isNotEmpty == true) noticeList.value = List.empty(growable: true);
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getNotice() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          try {
            var list = _response.resultMap?["data"] as List;
            List<NoticeModel> itemsList = list.map((i) => NoticeModel.fromJSON(i)).toList();
            noticeList?.addAll(itemsList);
          }catch(e) {
            print("getNotice() Error => $e");
            Util.toast("데이터를 가져오는 중 오류가 발생하였습니다.");
          }
        }
      }else{
        noticeList.value = List.empty(growable: true);
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getNotice() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getNotice() Error Default => ");
          break;
      }
    });
    return noticeList;
  }

  Future getSalesManage(BuildContext? context,String? auth, String? startDate, String? endDate) async {
    Logger logger = Logger();
    salesList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getSalesManageList(auth,startDate,endDate).then((it) {
      if (salesList.isNotEmpty == true) salesList.value = List.empty(growable: true);
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getSalesManage() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          try {
            var list = _response.resultMap?["data"] as List;
            List<SalesManageModel> itemsList = list.map((i) =>
                SalesManageModel.fromJSON(i)).toList();
            salesList?.addAll(itemsList);
          }catch(e) {
            Util.toast("데이터를 가져오는 중 오류가 발생하였습니다.");
          }
        }
      }else{
        salesList.value = List.empty(growable: true);
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getSalesManage() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getSalesManage() Error Default => ");
          break;
      }
    });
    return salesList;
  }

  Future getAddr(BuildContext? context, String? keyword) async {
    Logger logger = Logger();
    addrList.value = List.empty(growable: true);
    await DioService.jusoDioClient().getJuso(Const.JUSU_KEY,"1","20",keyword,"json").then((it) {
      if (addrList.isNotEmpty == true) addrList.value = List.empty(growable: true);
      addrList.value = DioService.jusoDioResponse(it);
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getAddr() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getAddr() Error Default => ");
          break;
      }
    });
    return addrList;
  }

  // 실적현황
  Future getMonitor(BuildContext context, String? auth, String? startDate, String? endDate, String? vehicId) async {
    Logger logger = Logger();
    monitorModel.value = MonitorModel();
    await DioService.dioClient(header: true).getMonitorOrder(auth,startDate,endDate,vehicId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getMonitor() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
            var data = _response.resultMap?["data"];
            MonitorModel monitor = MonitorModel();
            monitor.allCnt = data["allCnt"].toString();
            monitor.normalCnt = data["normalCnt"].toString();
            monitor.quickCnt = data["quickCnt"].toString();
            monitor.allCharge = data["allCharge"].toString();
            monitor.normalCharge = data["normalCharge"].toString();
            monitor.quickCharge = data["quickCharge"].toString();
            monitorModel.value = monitor;
        }else{
          monitorModel.value = MonitorModel();
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getMonitor() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getMonitor() Error Default => ");
          break;
      }
    });
    return monitorModel.value;
  }

  //차계부
  Future getCar(BuildContext context, String? auth) async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).getCar(auth).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getCar() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          var list = _response.resultMap?["data"] as List;
          List<CarModel> itemsList = list.map((i) => CarModel.fromJSON(i)).toList();
          if(regCarList.value.isNotEmpty) regCarList.clear();
          regCarList.value?.addAll(itemsList);
        }else{
          regCarList.value = List.empty(growable: true);
        }
      }else{
        Util.toast(_response.message);
        regCarList.value = List.empty(growable: true);
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
    return regCarList;
  }

  // 차계부 Tab별 리스트
  Future getTabList(String? auth,int? carSeq, String? startDate, String? endDate,String? tabValue ) async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).getCarBook(
        auth,
        carSeq,
        startDate,
        endDate,
        tabValue
    ).then((it) async {
      ReturnMap response = DioService.dioResponse(it);
      logger.d("getTabList() _response -> ${response.status} // ${response.resultMap}");
      if(response.status == "200") {
        if (response.resultMap?["data"] != null) {
          var list = response.resultMap?["data"] as List;
          if(tabCarList.value.isNotEmpty) tabCarList.clear();
          List<CarBookModel> itemsList = list.map((i) => CarBookModel.fromJSON(i)).toList();
          tabCarList.value?.addAll(itemsList);
        }else{
          tabCarList.value = List.empty(growable: true);
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getTabList() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getTabList() Error Default => ");
          break;
      }
    });
    return tabCarList;
  }

}