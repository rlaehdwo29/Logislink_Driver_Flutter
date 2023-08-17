import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_driver_flutter/common/model/result_model.dart';

part 'car_book_model.g.dart';

@JsonSerializable()
class CarBookModel extends ResultModel {
  int? carSeq;
  String? driverId;
  String? bookSeq;
  String? itemCode;
  String? bookDate;
  int? price;
  int? unit;
  int? total;
  int? mileage;
  int? fuel;
  int? refuelAmt;
  int? unitPrice;
  String? regDate;
  String? memo;

  CarBookModel({
    this.carSeq,
    this.driverId,
    this.bookSeq,
    this.itemCode,
    this.bookDate,
    this.price,
    this.unit,
    this.total,
    this.mileage,
    this.fuel,
    this.refuelAmt,
    this.unitPrice,
    this.regDate,
    this.memo
});

  factory CarBookModel.fromJSON(Map<String,dynamic> json) => _$CarBookModelFromJson(json);

  Map<String,dynamic> toJson() => _$CarBookModelToJson(this);

}