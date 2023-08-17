// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopPointModel _$StopPointModelFromJson(Map<String, dynamic> json) =>
    StopPointModel(
      orderId: json['orderId'] as String?,
      stopSeq: json['stopSeq'] as int?,
      stopNo: json['stopNo'] as int?,
      eComName: json['eComName'] as String?,
      eAddr: json['eAddr'] as String?,
      eAddrDetail: json['eAddrDetail'] as String?,
      eStaff: json['eStaff'] as String?,
      eTel: json['eTel'] as String?,
      beginYn: json['beginYn'] as String?,
      beginDate: json['beginDate'] as String?,
      finishYn: json['finishYn'] as String?,
      finishDate: json['finishDate'] as String?,
      goodsWeight: (json['goodsWeight'] as num?)?.toDouble(),
      eLat: (json['eLat'] as num?)?.toDouble(),
      eLon: (json['eLon'] as num?)?.toDouble(),
      weightUnitCode: json['weightUnitCode'] as String?,
      goodsQty: json['goodsQty'] as String?,
      qtyUnitCode: json['qtyUnitCode'] as String?,
      qtyUnitName: json['qtyUnitName'] as String?,
      goodsName: json['goodsName'] as String?,
      useYn: json['useYn'] as String?,
      stopSe: json['stopSe'] as String?,
      expend: json['expend'] as bool?,
    )
      ..status = json['status'] as String?
      ..message = json['message'] as String?
      ..path = json['path'] as String?
      ..resultMap = json['resultMap'] as Map<String, dynamic>?;

Map<String, dynamic> _$StopPointModelToJson(StopPointModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'path': instance.path,
      'resultMap': instance.resultMap,
      'orderId': instance.orderId,
      'stopSeq': instance.stopSeq,
      'stopNo': instance.stopNo,
      'eComName': instance.eComName,
      'eAddr': instance.eAddr,
      'eAddrDetail': instance.eAddrDetail,
      'eStaff': instance.eStaff,
      'eTel': instance.eTel,
      'beginYn': instance.beginYn,
      'beginDate': instance.beginDate,
      'finishYn': instance.finishYn,
      'finishDate': instance.finishDate,
      'goodsWeight': instance.goodsWeight,
      'eLat': instance.eLat,
      'eLon': instance.eLon,
      'weightUnitCode': instance.weightUnitCode,
      'goodsQty': instance.goodsQty,
      'qtyUnitCode': instance.qtyUnitCode,
      'qtyUnitName': instance.qtyUnitName,
      'goodsName': instance.goodsName,
      'useYn': instance.useYn,
      'stopSe': instance.stopSe,
      'expend': instance.expend,
    };
