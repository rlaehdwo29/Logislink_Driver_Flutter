import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_driver_flutter/common/model/result_model.dart';

part 'car_model.g.dart';

@JsonSerializable()
class CarModel extends ResultModel {
  int? carSeq;
  String? driverId;
  String? carName;
  String? carNum;
  String? mainYn;
  String? regDate;
  String? useYn;
  int? accMileage;

  CarModel({
    this.carSeq,
    this.driverId,
    this.carName,
    this.carNum,
    this.mainYn,
    this.regDate,
    this.useYn,
    this.accMileage
  });

  factory CarModel.fromJSON(Map<String,dynamic> json) => _$CarModelFromJson(json);

  Map<String,dynamic> toJson() => _$CarModelToJson(this);


}