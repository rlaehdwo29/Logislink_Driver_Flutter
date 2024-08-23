// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_manage_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesManageModel _$SalesManageModelFromJson(Map<String, dynamic> json) =>
    SalesManageModel(
      workId: json['workId'] as String?,
      driverId: json['driverId'] as String?,
      orderId: json['orderId'] as String?,
      visible: json['visible'] as String?,
      deposit: json['deposit'] as String?,
      depoDate: json['depoDate'] as String?,
      regDate: json['regDate'] as String?,
      driveDate: json['driveDate'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      orderComp: json['orderComp'] as String?,
      truckNetwork: json['truckNetwork'] as String?,
      money: (json['money'] as num?)?.toInt(),
      startLoc: json['startLoc'] as String?,
      endLoc: json['endLoc'] as String?,
      goodsName: json['goodsName'] as String?,
      receiptMethod: json['receiptMethod'] as String?,
      receiptDate: json['receiptDate'] as String?,
      taxMethod: json['taxMethod'] as String?,
      taxDate: json['taxDate'] as String?,
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$SalesManageModelToJson(SalesManageModel instance) =>
    <String, dynamic>{
      'workId': instance.workId,
      'driverId': instance.driverId,
      'orderId': instance.orderId,
      'visible': instance.visible,
      'deposit': instance.deposit,
      'depoDate': instance.depoDate,
      'regDate': instance.regDate,
      'driveDate': instance.driveDate,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'orderComp': instance.orderComp,
      'truckNetwork': instance.truckNetwork,
      'money': instance.money,
      'startLoc': instance.startLoc,
      'endLoc': instance.endLoc,
      'goodsName': instance.goodsName,
      'receiptMethod': instance.receiptMethod,
      'receiptDate': instance.receiptDate,
      'taxMethod': instance.taxMethod,
      'taxDate': instance.taxDate,
      'memo': instance.memo,
    };
