// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarBookModel _$CarBookModelFromJson(Map<String, dynamic> json) => CarBookModel(
      carSeq: json['carSeq'] as int?,
      driverId: json['driverId'] as String?,
      bookSeq: json['bookSeq'] as String?,
      itemCode: json['itemCode'] as String?,
      bookDate: json['bookDate'] as String?,
      price: json['price'] as int?,
      unit: json['unit'] as int?,
      total: json['total'] as int?,
      mileage: json['mileage'] as int?,
      fuel: json['fuel'] as int?,
      refuelAmt: json['refuelAmt'] as int?,
      unitPrice: json['unitPrice'] as int?,
      regDate: json['regDate'] as String?,
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$CarBookModelToJson(CarBookModel instance) =>
    <String, dynamic>{
      'carSeq': instance.carSeq,
      'driverId': instance.driverId,
      'bookSeq': instance.bookSeq,
      'itemCode': instance.itemCode,
      'bookDate': instance.bookDate,
      'price': instance.price,
      'unit': instance.unit,
      'total': instance.total,
      'mileage': instance.mileage,
      'fuel': instance.fuel,
      'refuelAmt': instance.refuelAmt,
      'unitPrice': instance.unitPrice,
      'regDate': instance.regDate,
      'memo': instance.memo,
    };
