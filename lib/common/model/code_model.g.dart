// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeModel _$CodeModelFromJson(Map<String, dynamic> json) => CodeModel(
      code: json['code'] as String?,
      codeName: json['codeName'] as String?,
      useYn: json['useYn'] as String?,
      memo: json['memo'] as String?,
    )..isCheck = json['isCheck'] as bool?;

Map<String, dynamic> _$CodeModelToJson(CodeModel instance) => <String, dynamic>{
      'code': instance.code,
      'codeName': instance.codeName,
      'useYn': instance.useYn,
      'memo': instance.memo,
      'isCheck': instance.isCheck,
    };
