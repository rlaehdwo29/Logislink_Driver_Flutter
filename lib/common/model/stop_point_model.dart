import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stop_point_model.g.dart';

@JsonSerializable()
class StopPointModel extends ReturnMap {
  String? orderId;
  int? stopSeq;
  int? stopNo;
  String? eComName;
  String? eAddr;
  String? eAddrDetail;
  String? eStaff;
  String? eTel;
  String? beginYn;
  String? beginDate;
  String? finishYn;
  String? finishDate;
  double? goodsWeight;
  double? eLat;
  double? eLon;
  String? weightUnitCode;
  String? goodsQty;
  String? qtyUnitCode;
  String? qtyUnitName;
  String? goodsName;
  String? useYn;
  String? stopSe;   //S:상차지, E:하차지
  bool? expend = false;

  StopPointModel({
    this.orderId,
    this.stopSeq,
    this.stopNo,
    this.eComName,
    this.eAddr,
    this.eAddrDetail,
    this.eStaff,
    this.eTel,
    this.beginYn,
    this.beginDate,
    this.finishYn,
    this.finishDate,
    this.goodsWeight,
    this.eLat,
    this.eLon,
    this.weightUnitCode,
    this.goodsQty,
    this.qtyUnitCode,
    this.qtyUnitName,
    this.goodsName,
    this.useYn,
    this.stopSe ,
    this.expend
});

  factory StopPointModel.fromJSON(Map<String,dynamic> json) => _$StopPointModelFromJson(json);

  Map<String,dynamic> toJson() => _$StopPointModelToJson(this);

}