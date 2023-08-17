import 'package:logislink_driver_flutter/common/model/result_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'user_car_model.g.dart';

@JsonSerializable()
class UserCarModel extends ResultModel {
  String? vehicId;
  String? carNum;
  String? carTypeCode;
  String? carTypeName;
  String? carTonCode;
  String? carTonName;
  String? bizName;
  String? bizNum;
  String? ceo;
  String? bizPost;
  String? bizAddr;
  String? bizAddrDetail;
  String? subBizNum;
  String? bizKind;
  String? bizCond;

  UserCarModel({
    this.vehicId,
    this.carNum,
    this.carTypeCode,
    this.carTypeName,
    this.carTonCode,
    this.carTonName,
    this.bizName,
    this.bizNum,
    this.ceo,
    this.bizPost,
    this.bizAddr,
    this.bizAddrDetail,
    this.subBizNum,
    this.bizKind,
    this.bizCond
});
  factory UserCarModel.fromJSON(Map<String,dynamic> json) => _$UserCarModelFromJson(json);

  Map<String,dynamic> toJson() => _$UserCarModelToJson(this);
}