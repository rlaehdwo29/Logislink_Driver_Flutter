
import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_driver_flutter/common/model/result_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends ResultModel {

  String? authorization;
  String? driverId;
  String? vehicId;
  String? driverName;
  String? carNum;
  String? mobile;
  String? telnum;
  String? pushYn;
  String? talkYn;
  String? bankCode;
  String? bankCnnm;
  String? bankAccount;
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
  String? driverEmail;
  int? vehicCnt;
  String? dangerGoodsYn;
  String? chemicalsYn;
  String? foreignLicenseYn;
  String? forkliftYn;
  String? cargoBox;
  String? bankchkDate; //예금주 확인일

  UserModel({
    this.authorization,
    this.driverId,
    this.vehicId,
    this.driverName,
    this.carNum,
    this.mobile,
    this.telnum,
    this.pushYn,
    this.talkYn,
    this.bankCode,
    this.bankCnnm,
    this.bankAccount,
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
    this.bizCond,
    this.driverEmail,
    this.vehicCnt,
    this.dangerGoodsYn,
    this.chemicalsYn,
    this.foreignLicenseYn,
    this.forkliftYn,
    this.cargoBox,
    this.bankchkDate
  });

  factory UserModel.fromJSON(Map<String,dynamic> json) => _$UserModelFromJson(json);

  Map<String,dynamic> toJson() => _$UserModelToJson(this);

  @override
  bool operator ==(Object other) {
    return other is UserModel &&
        other.authorization == this.authorization &&
        other.driverId == this.driverId &&
        other.vehicId == this.vehicId &&
        other.driverName == this.driverName &&
        other.carNum == this.carNum &&
        other.mobile == this.mobile &&
        other.telnum == this.telnum &&
        other.pushYn == this.pushYn &&
        other.talkYn == this.talkYn &&
        other.bankCode == this.bankCode &&
        other.bankCnnm == this.bankCnnm &&
        other.bankAccount == this.bankAccount &&
        other.carTypeCode == this.carTypeCode &&
        other.carTypeName == this.carTypeName &&
        other.carTonCode == this.carTonCode &&
        other.carTonName == this.carTonName &&
        other.bizName == this.bizName &&
        other.bizNum == this.bizNum &&
        other.ceo == this.ceo &&
        other.bizPost == this.bizPost &&
        other.bizAddr == this.bizAddr &&
        other.bizAddrDetail == this.bizAddrDetail &&
        other.subBizNum == this.subBizNum &&
        other.bizKind == this.bizKind &&
        other.bizCond == this.bizCond &&
        other.driverEmail == this.driverEmail &&
        other.vehicCnt == this.vehicCnt &&
        other.dangerGoodsYn == this.dangerGoodsYn &&
        other.chemicalsYn == this.chemicalsYn &&
        other.foreignLicenseYn == this.foreignLicenseYn &&
        other.forkliftYn == this.forkliftYn &&
        other.cargoBox == this.cargoBox &&
        other.bankchkDate == this.bankchkDate;
  }

  @override
  int get hashCode {
        return this.authorization.hashCode +
        this.driverId.hashCode +
        this.vehicId.hashCode +
        this.driverName.hashCode +
        this.carNum.hashCode +
        this.mobile.hashCode +
        this.telnum.hashCode +
        this.pushYn.hashCode +
        this.talkYn.hashCode +
        this.bankCode.hashCode +
        this.bankCnnm.hashCode +
        this.bankAccount.hashCode +
        this.carTypeCode.hashCode +
        this.carTypeName.hashCode +
        this.carTonCode.hashCode +
        this.carTonName.hashCode +
        this.bizName.hashCode +
        this.bizNum.hashCode +
        this.ceo.hashCode +
        this.bizPost.hashCode +
        this.bizAddr.hashCode +
        this.bizAddrDetail.hashCode +
        this.subBizNum.hashCode +
        this.bizKind.hashCode +
        this.bizCond.hashCode +
        this.driverEmail.hashCode +
        this.vehicCnt.hashCode +
        this.dangerGoodsYn.hashCode +
        this.chemicalsYn.hashCode +
        this.foreignLicenseYn.hashCode +
        this.forkliftYn.hashCode +
        this.cargoBox.hashCode +
        this.bankchkDate.hashCode;
  }

}