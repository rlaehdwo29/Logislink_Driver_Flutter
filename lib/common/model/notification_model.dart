import 'package:json_annotation/json_annotation.dart';
import 'package:logislink_driver_flutter/common/model/result_model.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel extends ResultModel {

  int? msgSeq;
  String? orderId;
  String? allocId;
  String? title;
  String? contents;
  String? sendDate;

  NotificationModel({
    this.msgSeq,
    this.orderId,
    this.allocId,
    this.title,
    this.contents,
    this.sendDate
  });

  factory NotificationModel.fromJSON(Map<String,dynamic> json) {
    NotificationModel notification = NotificationModel(
        msgSeq : json['msgSeq'],
        orderId : json['orderId'],
        allocId : json['allocId'],
        title : json['title'],
        contents : json['contents'],
        sendDate : json['sendDate']
    );
    return notification;
  }

  Map<String,dynamic> toJson() => _$NotificationModelToJson(this);

}