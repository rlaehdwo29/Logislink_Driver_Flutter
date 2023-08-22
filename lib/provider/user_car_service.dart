import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/user_car_model.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:dio/dio.dart';

class UserCarInfoService with ChangeNotifier {

  final userCarList = List.empty(growable: true).obs;

  UserCarInfoService() {
    userCarList.value = List.empty(growable: true);
  }

  void init() {
    userCarList.value = List.empty(growable: true);
  }

  Future getUserCarInfo(String? auth) async {
    Logger logger = Logger();
    userCarList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getUserCarInfo(auth).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.i("getUserCarInfo() _response -> ${_response.status} // ${_response.resultMap}");
      if (_response.status == "200") {
        if(_response.resultMap?["data"] != null) {
          try {
          var list = _response.resultMap?["data"] as List;
          List<UserCarModel> itemsList = list.map((i) => UserCarModel.fromJSON(i)).toList();
          userCarList?.addAll(itemsList);
          }catch(e) {
            print(e);
          }
        }else{
          userCarList.value = List.empty(growable: true);
        }
      }
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getUserCarInfo() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getUserCarInfo() Error Default => ");
          break;
      }
    });
    return userCarList;
  }

}