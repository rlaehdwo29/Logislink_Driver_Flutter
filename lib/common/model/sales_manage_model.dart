import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_driver_flutter/common/model/result_model.dart';

part 'sales_manage_model.g.dart';

@JsonSerializable()
class SalesManageModel extends ResultModel {
  String? workId;          // 매출관리 항목 등록 ID
  String? driverId;        // 차주 ID
  String? orderId;         // 오더 ID (내부 오더 연결시 기록)
  String? visible;         // 삭제 여부.
  String? deposit;         // 입금 확인
  String? depoDate;        // 입금 확인 여부
  String? regDate;         // 수정날짜
  String? driveDate;       // 운행일자
  String? startDate;       // 상차일자
  String? endDate;         // 하차일자
  String? orderComp;       // 오더 준 업체(청구업체)
  String? truckNetwork;    // 화물잡은곳(화물정보망)
  int? money;           // 운임
  String? startLoc;        // 출발지역
  String? endLoc;          // 도착지역
  String? goodsName;       // 화물정보
  String? receiptMethod;   // 인수증발송(전송) 방법
  String? receiptDate;     // 인수증발송(전송) 날짜
  String? taxMethod;       // 세금계산서 방법
  String? taxDate;         // 세금계산서 날짜
  String? memo;            // 특이사항, 메모

  SalesManageModel({
    this.workId,
    this.driverId,
    this.orderId,
    this.visible,
    this.deposit,
    this.depoDate,
    this.regDate,
    this.driveDate,
    this.startDate,
    this.endDate,
    this.orderComp,
    this.truckNetwork,
    this.money,
    this.startLoc,
    this.endLoc,
    this.goodsName,
    this.receiptMethod,
    this.receiptDate,
    this.taxMethod,
    this.taxDate,
    this.memo,
  });

  factory SalesManageModel.fromJSON(Map<String,dynamic> json) => _$SalesManageModelFromJson(json);

  Map<String,dynamic> toJson() => _$SalesManageModelToJson(this);

}