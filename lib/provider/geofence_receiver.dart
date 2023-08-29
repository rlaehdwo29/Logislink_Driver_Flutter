import 'dart:async';

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/geofence_model.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/db/appdatabase.dart';
import 'package:dio/dio.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';

class GeoFenceReceiver {

  static final _activityStreamController = StreamController<Activity>();
  static final _geofenceStreamController = StreamController<Geofence>();

  static GeofenceService? _geofenceService;

  // This function is to be called when the geofence status is changed.
  static Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    _geofenceStreamController.sink.add(geofence);
    AppDataBase db = App().getRepository();
    GeofenceModel? data = await db.getGeoFence(App().getUserInfo()?.vehicId, int.parse(geofence.id));
    print("하아아아=>${data?.allocState} // ${data}");
    if(data != null) {
      if(data.flag == "Y") {
        if(geofenceStatus == GeofenceStatus.ENTER) {
          if(data.allocState == "E") {
            if(await db.checkEndGeo(App().getUserInfo()?.vehicId, data.orderId) == 1) {
              setOrderState(data, "05");
            }
          } else if(data.allocState == "EP" || data.allocState == "SP") {
            if(data.allocState == "EP") {
              bool? checkGeoEPoint = await db.checkEPointGeo(App().getUserInfo()?.vehicId, data.orderId, data.stopNum);
              if(checkGeoEPoint??false) {
                finishStopPoint(data);
              }
            }
          }else{
            setOrderState(data, "12");
          }
        }else if(geofenceStatus == GeofenceStatus.EXIT) {
          if(data.allocState == "E") {
            if(await db.checkStartGeo(App().getUserInfo()?.vehicId, data.orderId) == 0) {
              setOrderState(data, "06");
            }
          }else if(data.allocState == "SP" || data.allocState == "EP"){
            bool? checkGeoSPoint = await db.checkSPointGeo(App().getUserInfo()?.vehicId, data.orderId, data.stopNum);
            if(checkGeoSPoint??false) {
              beginStartPoint(data);
            }
          }else{
            setOrderState(data, "04");
          }
        }
      }
    }
  }

  // This function is to be called when the activity has changed.
  static void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

  // This function is to be called when the location has changed.
  static void _onLocationChanged(Location location) {
    print('location: ${location.toJson()}');
  }

  // This function is to be called when a location services status change occurs
  // since the service was started.
  static void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  static void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }
    print('ErrorCode: $errorCode');
  }

  static Future<void> setOrderState(GeofenceModel data, String code) async {
    Logger logger = Logger();
    await DioService.dioClient(header: true).setOrderState(App().getUserInfo()?.authorization, data?.orderId, data?.allocId, code).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("geofence_receiver setOrderState() _response -> ${_response.status} // ${_response.resultMap} // $code");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          switch(code) {
            case "04":
            case "06":
              AppDataBase db = App().getRepository();
              db.delete(data);
              FBroadcast.instance().broadcast(Const.INTENT_GEOFENCE);
              break;
          }
          FBroadcast.instance().broadcast(Const.INTENT_DETAIL_REFRESH);
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("geofence_receiver.dart setOrderState() Error Default: ${res?.statusCode} -> ${res?.statusCode} // ${res?.statusMessage} // ${res}");
          break;
        default:
          logger.e("geofence_receiver.dart setOrderState() Error Default:");
          break;
      }
    });
  }

  static Future<void> beginStartPoint(GeofenceModel data) async {
    AppDataBase db = App().getRepository();
    String? stopSeq = data.stopNum.toString();

    GeofenceModel? removeGeo = await db.getRemoveGeoSEP(data.vehicId, data.orderId, data.allocState, data.stopNum);
    if(removeGeo != null) {
      db.deleteGeoFence(data.vehicId, data.orderId, data.allocState, data.stopNum);
    }

    Logger logger = Logger();
    await DioService.dioClient(header: true).beginStartPoint(App().getUserInfo()?.authorization,data.orderId,stopSeq).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("geofence_receiver finishStopPoint() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          FBroadcast.instance().broadcast(Const.INTENT_DETAIL_REFRESH);
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("geofence_receiver.dart finishStopPoint() Error Default: ${res?.statusCode} -> ${res?.statusCode} // ${res?.statusMessage} // ${res}");
          break;
        default:
          logger.e("geofence_receiver.dart finishStopPoint() Error Default:");
          break;
      }
    });

  }

  static Future<void> finishStopPoint(GeofenceModel data) async {
    AppDataBase db = App().getRepository();
      String? stopSeq = data.stopNum.toString();

      GeofenceModel? removeGeo = await db.getRemoveGeoSEP(data.vehicId, data.orderId, data.allocState, data.stopNum);
      if(removeGeo != null) {
        db.deleteGeoFence(data.vehicId, data.orderId, data.allocState, data.stopNum);
      }

    Logger logger = Logger();
    await DioService.dioClient(header: true).finishStopPoint(App().getUserInfo()?.authorization,data.orderId,stopSeq).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("geofence_receiver finishStopPoint() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if(_response.resultMap?["result"] == true) {
          FBroadcast.instance().broadcast(Const.INTENT_DETAIL_REFRESH);
        }
      }
    }).catchError((Object obj) async {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("geofence_receiver.dart finishStopPoint() Error Default: ${res?.statusCode} -> ${res?.statusCode} // ${res?.statusMessage} // ${res}");
          break;
        default:
          logger.e("geofence_receiver.dart finishStopPoint() Error Default:");
          break;
      }
    });

  }

  static void initGeoFence(List<Geofence>? mList) {

    // Create a [GeofenceService] instance and set options.
    _geofenceService = GeofenceService.instance.setup(
        interval: 5000,
        accuracy: 100,
        loiteringDelayMs: 60000,
        statusChangeDelayMs: 10000,
        useActivityRecognition: true,
        allowMockLocations: false,
        printDevLog: false,
        geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

    _geofenceService?.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService?.addLocationChangeListener(_onLocationChanged);
    _geofenceService?.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
    _geofenceService?.addActivityChangeListener(_onActivityChanged);
    _geofenceService?.addStreamErrorListener(_onError);
    _geofenceService?.start(mList).catchError(_onError);
    _geofenceService?.isRunningService;
  }

  static void stopGeofence() {
    _geofenceService?.removeGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService?.removeLocationChangeListener(_onLocationChanged);
    _geofenceService?.removeLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
    _geofenceService?.removeActivityChangeListener(_onActivityChanged);
    _geofenceService?.removeStreamErrorListener(_onError);
    _geofenceService?.clearAllListeners();
    _geofenceService?.stop();
  }


}