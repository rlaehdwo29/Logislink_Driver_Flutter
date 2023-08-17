// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitorModel _$MonitorModelFromJson(Map<String, dynamic> json) => MonitorModel(
      allCnt: json['allCnt'] as String?,
      normalCnt: json['normalCnt'] as String?,
      quickCnt: json['quickCnt'] as String?,
      allCharge: json['allCharge'] as String?,
      normalCharge: json['normalCharge'] as String?,
      quickCharge: json['quickCharge'] as String?,
    );

Map<String, dynamic> _$MonitorModelToJson(MonitorModel instance) =>
    <String, dynamic>{
      'allCnt': instance.allCnt,
      'normalCnt': instance.normalCnt,
      'quickCnt': instance.quickCnt,
      'allCharge': instance.allCharge,
      'normalCharge': instance.normalCharge,
      'quickCharge': instance.quickCharge,
    };
