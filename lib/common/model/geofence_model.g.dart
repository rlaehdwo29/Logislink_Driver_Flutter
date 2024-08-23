// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeofenceModel _$GeofenceModelFromJson(Map<String, dynamic> json) =>
    GeofenceModel(
      vehicId: json['vehicId'] as String?,
      orderId: json['orderId'] as String?,
      allocId: json['allocId'] as String?,
      allocState: json['allocState'] as String?,
      lat: json['lat'] as String,
      lon: json['lon'] as String,
      endDate: json['endDate'] as String?,
      flag: json['flag'] as String?,
      stopNum: (json['stopNum'] as num?)?.toInt(),
    )..id = (json['id'] as num?)?.toInt();

Map<String, dynamic> _$GeofenceModelToJson(GeofenceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicId': instance.vehicId,
      'orderId': instance.orderId,
      'allocId': instance.allocId,
      'allocState': instance.allocState,
      'lat': instance.lat,
      'lon': instance.lon,
      'endDate': instance.endDate,
      'flag': instance.flag,
      'stopNum': instance.stopNum,
    };
