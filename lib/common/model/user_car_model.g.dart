// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_car_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCarModel _$UserCarModelFromJson(Map<String, dynamic> json) => UserCarModel(
      vehicId: json['vehicId'] as String?,
      carNum: json['carNum'] as String?,
      carTypeCode: json['carTypeCode'] as String?,
      carTypeName: json['carTypeName'] as String?,
      carTonCode: json['carTonCode'] as String?,
      carTonName: json['carTonName'] as String?,
      bizName: json['bizName'] as String?,
      bizNum: json['bizNum'] as String?,
      ceo: json['ceo'] as String?,
      bizPost: json['bizPost'] as String?,
      bizAddr: json['bizAddr'] as String?,
      bizAddrDetail: json['bizAddrDetail'] as String?,
      subBizNum: json['subBizNum'] as String?,
      bizKind: json['bizKind'] as String?,
      bizCond: json['bizCond'] as String?,
    );

Map<String, dynamic> _$UserCarModelToJson(UserCarModel instance) =>
    <String, dynamic>{
      'vehicId': instance.vehicId,
      'carNum': instance.carNum,
      'carTypeCode': instance.carTypeCode,
      'carTypeName': instance.carTypeName,
      'carTonCode': instance.carTonCode,
      'carTonName': instance.carTonName,
      'bizName': instance.bizName,
      'bizNum': instance.bizNum,
      'ceo': instance.ceo,
      'bizPost': instance.bizPost,
      'bizAddr': instance.bizAddr,
      'bizAddrDetail': instance.bizAddrDetail,
      'subBizNum': instance.subBizNum,
      'bizKind': instance.bizKind,
      'bizCond': instance.bizCond,
    };
