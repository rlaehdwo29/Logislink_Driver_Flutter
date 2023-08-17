import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_driver_flutter/common/model/result_model.dart';

part 'monitor_model.g.dart';

@JsonSerializable()
class MonitorModel extends ResultModel {

  String? allCnt;
  String? normalCnt;
  String? quickCnt;
  String? allCharge;
  String? normalCharge;
  String? quickCharge;

  MonitorModel({
    this.allCnt,
    this.normalCnt,
    this.quickCnt,
    this.allCharge,
    this.normalCharge,
    this.quickCharge
  });

  factory MonitorModel.fromJSON(Map<String,dynamic> json) => _$MonitorModelFromJson(json);

  Map<String,dynamic> toJson() => _$MonitorModelToJson(this);
}