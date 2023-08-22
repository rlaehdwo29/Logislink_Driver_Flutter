import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_driver_flutter/common/model/result_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel extends ResultModel {

  String? orderId;             //오더 ID
  String? allocId;             //매출 배차 ID
  String? inOutSctn;           //수출입구분(내수, 수출입)
  String? inOutSctnName;
  String? truckTypeCode;       //운송유형
  String? truckTypeName;
  String? sComName;            //상차지명
  String? sSido;               //상차지시도
  String? sGungu;              //상차지군구
  String? sDong;               //상차지동
  String? sAddr;               //상차지주소
  String? sAddrDetail;         //상차지상세주소
  String? sDate;               //상차일 (YYYY-MM-DD HH:mm:ss)
  String? sStaff;              //상차지담당자
  String? sTel;                //상차지 연락처
  String? sMemo;               //상차지메모
  String? eComName;            //하차지명
  String? eSido;               //하차지시도
  String? eGungu;              //하차지군구
  String? eDong;               //하차지 동
  String? eAddr;               //하차지 주소
  String? eAddrDetail;         //하차지 상세주소
  String? eDate;               //하차일 (YYYY-MM-DD HH:mm:ss)
  String? eStaff;              //하차지 담당자
  String? eTel;                //하차지 연락처
  String? eMemo;               //하차지 메모
  double? sLat;
  double? sLon;
  double? eLat;
  double? eLon;
  String? goodsName;           //화물정보
  String? goodsWeight;         //화물중량
  String? weightUnitCode;      //중량단위코드
  String? goodsQty;            //화물수량
  String? qtyUnitCode;         //수량단위코드
  String? sWayCode;            //상차방법
  String? eWayCode;            //하차방법
  String? mixYn;               //혼적여부
  String? mixSize;             //혼적크기
  String? returnYn;            //왕복여부
  String? carTonCode;
  String? carTypeCode;
  String? chargeType;          //운임구분코드(인수증.선착불)
  double? distance;
  int? time;
  String? driverMemo;          //차주 확인사항
  String? itemCode;            //운송품목코드
  String? itemName;
  int? stopCount;              //경유지
  String? qtyUnitName;
  String? sWayName;
  String? eWayName;
  String? chargeTypeName;      //운임구분코드(인수증.선착불)
  String? carTypeName;
  String? carTonName;

  /* 운송사 정보  */
  String? sellCustId;          //매출 거래처 ID
  String? sellDeptId;          //매출 부서 ID
  String? sellStaff;           //매출거래처 담당자
  String? sellStaffTel;        //담당자 연락처
  String? sellCustName;
  String? sellDeptName;
  String? sellCharge;          //매출운송비
  String? sellFee;             //매출수수료

  String? allocState;          //배차상태
  String? allocStateName;      //배차상태
  String? allocDate;           //배차일
  String? startDate;           //출발일
  String? finishDate;          //도착일
  String? enterDate;           //입차일

  String? receiptYn;           //인수증접수여부 (Y/P일 경우 접수 상태, 인수증은 종이랑 사진 동시 확인함)
  String? receiptDate;         //인수증접수일(해당 컬럼 값이 있을 경우, 사진인수증 접수)
  String? receiptPath;         //인수증 경로
  String? paperReceiptDate;    //인수증접수일(종이) (해당 컬럼 값이 있을 경우, 종이인수증 접수)

  String? invId;               //세금계산서 ID
  String? taxinvYn;            //세금계산서 발행여부 (R:대기, Y:전자, P:일반)
  String? taxinvDate;          //발행일자 (세금계산서는 전자/일반 둘 중 하나임)
  String? loadStatus;          //0: 전자발행 전, 1: 전자발행 요청, 2: 전자발행 완료

  String? payType;             //빠른지급 오더(해당 :Y, 미해당 :N)
  String? reqPayYN;            //차주 빠른지급 신청(신청 : Y, 신청전 : N)
  String? reqPayDate;          //빠른지급신청일
  String? payDate;             //지급일 (실제 운임 지급일)
  String? payAmt;              //지급액 (실제 지급 금액)
  double? reqPayFee;              //빠른출금 수수료율

  String? finishYn;            //정산 마감 처리 여부 확인 (Y: 완료, N: 미완료)

  String? autoCarTimeYn;       //Geo 값 On/Off 업체 설정 (Y: 출입차 자동 처리, N: 업체 미 적용)

  OrderModel({
    this.orderId,
    this.allocId,
    this.inOutSctn,
    this.inOutSctnName,
    this.truckTypeCode,
    this.truckTypeName,
    this.sComName,
    this.sSido,
    this.sGungu,
    this.sDong,
    this.sAddr,
    this.sAddrDetail,
    this.sDate,
    this.sStaff,
    this.sTel,
    this.sMemo,
    this.eComName,
    this.eSido,
    this.eGungu,
    this.eDong,
    this.eAddr,
    this.eAddrDetail,
    this.eDate,
    this.eStaff,
    this.eTel,
    this.eMemo,
    this.sLat,
    this.sLon,
    this.eLat,
    this.eLon,
    this.goodsName,
    this.goodsWeight,
    this.weightUnitCode,
    this.goodsQty,
    this.qtyUnitCode,
    this.sWayCode,
    this.eWayCode,
    this.mixYn,
    this.mixSize,
    this.returnYn,
    this.carTonCode,
    this.carTypeCode,
    this.chargeType,
    this.distance,
    this.time,
    this.driverMemo,
    this.itemCode,
    this.itemName,
    this.stopCount,
    this.qtyUnitName,
    this.sWayName,
    this.eWayName,
    this.chargeTypeName,
    this.carTypeName,
    this.carTonName,
    this.sellCustId,
    this.sellDeptId,
    this.sellStaff,
    this.sellStaffTel,
    this.sellCustName,
    this.sellDeptName,
    this.sellCharge,
    this.sellFee,
    this.allocState,
    this.allocStateName,
    this.allocDate,
    this.startDate,
    this.finishDate,
    this.enterDate,
    this.receiptYn,
    this.receiptDate,
    this.receiptPath,
    this.paperReceiptDate,
    this.invId,
    this.taxinvYn,
    this.taxinvDate,
    this.loadStatus,
    this.payType,
    this.reqPayYN,
    this.reqPayDate,
    this.payDate,
    this.payAmt,
    this.reqPayFee,
    this.finishYn,
    this.autoCarTimeYn,
  });

  factory OrderModel.fromJSON(Map<String,dynamic> json) {
    OrderModel order = OrderModel(
      orderId:json['orderId'],
      allocId:json['allocId'],
      inOutSctn:json['inOutSctn'].toString(),
      inOutSctnName:json['inOutSctnName'],
      truckTypeCode:json['truckTypeCode'],
      truckTypeName:json['truckTypeName'],
      sComName:json['sComName'],
      sSido:json['sSido'],
      sGungu:json['sGungu'],
      sDong:json['sDong'],
      sAddr:json['sAddr'],
      sAddrDetail:json['sAddrDetail'],
      sDate:json['sDate'],
      sStaff:json['sStaff'],
      sTel:json['sTel'],
      sMemo:json['sMemo'],
      eComName:json['eComName'],
      eSido:json['eSido'],
      eGungu:json['eGungu'],
      eDong:json['eDong'],
      eAddr:json['eAddr'],
      eAddrDetail:json['eAddrDetail'],
      eDate:json['eDate'],
      eStaff:json['eStaff'],
      eTel:json['eTel'],
      eMemo:json['eMemo'],
      sLat:double.parse((json['sLat'] ?? 0.0).toString()),
      sLon:double.parse((json['sLon'] ?? 0.0).toString()),
      eLat:double.parse((json['eLat'] ?? 0.0).toString()),
      eLon:double.parse((json['eLon'] ?? 0.0).toString()),
      goodsName:json['goodsName'],
      goodsWeight:json['goodsWeight'].toString(),
      weightUnitCode:json['weightUnitCode'],
      goodsQty:json['goodsQty'].toString(),
      qtyUnitCode:json['qtyUnitCode'],
      sWayCode:json['sWayCode'],
      eWayCode:json['eWayCode'],
      mixYn:json['mixYn'],
      mixSize:json['mixSize'],
      returnYn:json['returnYn'],
      carTonCode:json['carTonCode'],
      carTypeCode:json['carTypeCode'].toString(),
      chargeType:json['chargeType'].toString(),
      distance:double.parse((json['distance'] ?? 0.0).toString()),
      time:json['time'],
      driverMemo:json['driverMemo'],
      itemCode:json['itemCode'].toString(),
      itemName:json['itemName'],
      stopCount:json['stopCount'],
      qtyUnitName:json['qtyUnitName'],
      sWayName:json['sWayName'],
      eWayName:json['eWayName'],
      chargeTypeName:json['chargeTypeName'],
      carTypeName:json['carTypeName'],
      carTonName:json['carTonName'],
      sellCustId:json['sellCustId'],
      sellDeptId:json['sellDeptId'],
      sellStaff:json['sellStaff'],
      sellStaffTel:json['sellStaffTel'],
      sellCustName:json['sellCustName'],
      sellDeptName:json['sellDeptName'],
      sellCharge:json['sellCharge'].toString(),
      sellFee:json['sellFee'].toString(),
      allocState:json['allocState'].toString(),
      allocStateName:json['allocStateName'],
      allocDate:json['allocDate'],
      startDate:json['startDate'],
      finishDate:json['finishDate'],
      enterDate:json['enterDate'],
      receiptYn:json['receiptYn'],
      receiptDate:json['receiptDate'],
      receiptPath:json['receiptPath'],
      paperReceiptDate:json['paperReceiptDate'],
      invId:json['invId'],
      taxinvYn:json['taxinvYn'],
      taxinvDate:json['taxinvDate'],
      loadStatus:json['loadStatus'],
      payType:json['payType'],
      reqPayYN:json['reqPayYN'],
      reqPayDate:json['reqPayDate'],
      payDate:json['payDate'],
      payAmt:json['payAmt'],
      reqPayFee:double.parse((json['reqPayFee'] ?? 0.0).toString()),
      finishYn:json['finishYn'],
      autoCarTimeYn:json['autoCarTimeYn']
    );
    return order;
  }

  Map<String,dynamic> toJson() => _$OrderModelToJson(this);

}