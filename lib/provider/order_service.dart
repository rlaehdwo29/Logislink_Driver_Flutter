import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/order_model.dart';
import 'package:logislink_driver_flutter/common/model/stop_point_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class OrderService with ChangeNotifier {

  final orderList = List.empty(growable: true).obs;
  List<StopPointModel> stopPointList = List.empty(growable: true);
  List<OrderModel> historyList = List.empty(growable: true);

  OrderService() {
    orderList.value = List.empty(growable: true);
    stopPointList = List.empty(growable: true);
    historyList = List.empty(growable: true);
  }

  void init() {
    orderList.value = List.empty(growable: true);
    stopPointList = List.empty(growable: true);
    historyList = List.empty(growable: true);
  }

  Future getHistory(BuildContext? context, String? _auth, String? _fromDate, String? _toDate, String? _vehicId, String? _receiptYn, String? _taxYn, String? _payType, String? _payYn) async {
    Logger logger = Logger();
    historyList = List.empty(growable: true);
    await DioService.dioClient(header: true).getHistory(_auth, _fromDate, _toDate, _vehicId, _receiptYn, _taxYn, _payType, _payYn).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getHistory() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          var list = _response.resultMap?["data"] as List;
          List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
          historyList?.addAll(itemsList);
        }else{
          historyList = List.empty(growable: true);
        }
      }
    }).catchError((Object obj){
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
    return historyList;
  }

  Future getStopPoint(BuildContext? context, String? auth, String? orderId) async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).getStopPoint(auth, orderId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getStopPoint() _response -> ${_response.status} // ${_response.resultMap}");

      if(_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
          try{
            var list = _response.resultMap?["data"] as List;
            List<StopPointModel> itemsList = list.map((i) => StopPointModel.fromJSON(i)).toList();
            if(stopPointList.isNotEmpty) stopPointList.clear();
            stopPointList?.addAll(itemsList);
          }catch(e) {
            print(e);
          }
        } else {
          stopPointList = List.empty(growable: true);
        }
      }

    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getStopPoint() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getStopPoint() Error Default => ");
          break;
      }
    });
    return stopPointList;
  }

  Future getOrder(context, String? auth, String? vehicId) async {
    Logger logger = Logger();
    orderList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getOrder(auth, vehicId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOrder() _response -> ${_response.status} // ${_response.resultMap}");
      //openOkBox(context,_response.resultMap!["data"].toString(),Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      if(_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
          try{
            var list = _response.resultMap?["data"] as List;
            List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
            orderList?.addAll(itemsList);
          }catch(e) {
            print(e);
          }
        } else {
          orderList.value = List.empty(growable: true);
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getOrder() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrder() getOrder Default => ");
          break;
      }
    });
    return orderList;
  }


  Future getOrderList2(context, String? auth, String? allocId, String? orderId) async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).getOrderList2(auth, allocId, orderId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getOrderList2() _response -> ${_response.status} // ${_response.resultMap}");
      //openOkBox(context,_response.resultMap!["data"].toString(),Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
      if(_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
          try{
            var list = _response.resultMap?["data"] as List;
            List<OrderModel> itemsList = list.map((i) => OrderModel.fromJSON(i)).toList();
            orderList!.isNotEmpty? orderList.value = List.empty(growable: true) : orderList?.addAll(itemsList);
          }catch(e) {
            print(e);
          }
        } else {
          orderList.value = List.empty(growable: true);
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getOrderList2() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getOrderList2() getOrder Default => ");
          break;
      }
    });
    return orderList;
  }


}