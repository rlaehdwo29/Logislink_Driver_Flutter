import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_driver_flutter/common/model/result_model.dart';

part 'stop_point_gps_model.g.dart';

@JsonSerializable()
class StopPointGpsModel extends ResultModel {

  String? orderId;
  String? vehicId;
  String? allocId;
  String? comName;
  String? addr;
  String? addrDetail;
  String? staff;
  String? tel;
  String? pointLat;
  String? pointLon;
  String? weightUnitCode;
  String? goodsQty;
  String? qtyUnitCode;
  String? goodsName;
  int? stopNo;
  String? stopSe;
  int? stopSeq;
  String? goodsWeight;
  String? autoCarTimeYn;
  String? endDate;
  String? beginYn;
  String? finishYn;

  StopPointGpsModel({
    this.orderId,
    this.vehicId,
    this.allocId,
    this.comName,
    this.addr,
    this.addrDetail,
    this.staff,
    this.tel,
    this.pointLat,
    this.pointLon,
    this.weightUnitCode,
    this.goodsQty,
    this.qtyUnitCode,
    this.goodsName,
    this.stopNo,
    this.stopSeq,
    this.stopSe,
    this.goodsWeight,
    this.autoCarTimeYn,
    this.endDate,
    this.beginYn,
    this.finishYn
  });

  factory StopPointGpsModel.fromJSON(Map<String,dynamic> json) => _$StopPointGpsModelFromJson(json);

  Map<String,dynamic> toJson() => _$StopPointGpsModelToJson(this);


}