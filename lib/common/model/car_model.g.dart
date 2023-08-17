// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarModel _$CarModelFromJson(Map<String, dynamic> json) => CarModel(
      carSeq: json['carSeq'] as int?,
      driverId: json['driverId'] as String?,
      carName: json['carName'] as String?,
      carNum: json['carNum'] as String?,
      mainYn: json['mainYn'] as String?,
      regDate: json['regDate'] as String?,
      useYn: json['useYn'] as String?,
      accMileage: json['accMileage'] as int?,
    );

Map<String, dynamic> _$CarModelToJson(CarModel instance) => <String, dynamic>{
      'carSeq': instance.carSeq,
      'driverId': instance.driverId,
      'carName': instance.carName,
      'carNum': instance.carNum,
      'mainYn': instance.mainYn,
      'regDate': instance.regDate,
      'useYn': instance.useYn,
      'accMileage': instance.accMileage,
    };
