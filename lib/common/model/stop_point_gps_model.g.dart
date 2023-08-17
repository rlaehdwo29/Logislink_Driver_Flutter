// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_point_gps_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopPointGpsModel _$StopPointGpsModelFromJson(Map<String, dynamic> json) =>
    StopPointGpsModel(
      orderId: json['orderId'] as String?,
      vehicId: json['vehicId'] as String?,
      allocId: json['allocId'] as String?,
      comName: json['comName'] as String?,
      addr: json['addr'] as String?,
      addrDetail: json['addrDetail'] as String?,
      staff: json['staff'] as String?,
      tel: json['tel'] as String?,
      pointLat: json['pointLat'] as String?,
      pointLon: json['pointLon'] as String?,
      weightUnitCode: json['weightUnitCode'] as String?,
      goodsQty: json['goodsQty'] as String?,
      qtyUnitCode: json['qtyUnitCode'] as String?,
      goodsName: json['goodsName'] as String?,
      stopNo: json['stopNo'] as int?,
      stopSeq: json['stopSeq'] as int?,
      stopSe: json['stopSe'] as String?,
      goodsWeight: json['goodsWeight'] as String?,
      autoCarTimeYn: json['autoCarTimeYn'] as String?,
      endDate: json['endDate'] as String?,
      beginYn: json['beginYn'] as String?,
      finishYn: json['finishYn'] as String?,
    );

Map<String, dynamic> _$StopPointGpsModelToJson(StopPointGpsModel instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'vehicId': instance.vehicId,
      'allocId': instance.allocId,
      'comName': instance.comName,
      'addr': instance.addr,
      'addrDetail': instance.addrDetail,
      'staff': instance.staff,
      'tel': instance.tel,
      'pointLat': instance.pointLat,
      'pointLon': instance.pointLon,
      'weightUnitCode': instance.weightUnitCode,
      'goodsQty': instance.goodsQty,
      'qtyUnitCode': instance.qtyUnitCode,
      'goodsName': instance.goodsName,
      'stopNo': instance.stopNo,
      'stopSe': instance.stopSe,
      'stopSeq': instance.stopSeq,
      'goodsWeight': instance.goodsWeight,
      'autoCarTimeYn': instance.autoCarTimeYn,
      'endDate': instance.endDate,
      'beginYn': instance.beginYn,
      'finishYn': instance.finishYn,
    };
