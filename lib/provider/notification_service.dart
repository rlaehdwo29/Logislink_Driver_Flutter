import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/notification_model.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:dio/dio.dart';

class NotificationService with ChangeNotifier {
  final notificationList = List.empty(growable: true).obs;

  NotificationService() {
    notificationList.value = List.empty(growable: true);
  }

  void init() {
    notificationList.value = List.empty(growable: true);
  }

  Future getNotification(BuildContext? context, String? _auth) async {
    Logger logger = Logger();
    notificationList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getNotification(_auth).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getNotification() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          var list = _response.resultMap?["data"] as List;
          List<NotificationModel> itemsList = list.map((i) => NotificationModel.fromJSON(i)).toList();
          if (notificationList.isNotEmpty == true) notificationList.value = List.empty(growable: true);
          notificationList.value?.addAll(itemsList);
        }else{
          notificationList.value = List.empty(growable: true);
        }
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getNotification() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getNotification() Error Default => ");
          break;
      }
    });
    return notificationList;
  }

}