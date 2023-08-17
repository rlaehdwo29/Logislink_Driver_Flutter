import 'package:json_annotation/json_annotation.dart';

part 'geofence_model.g.dart';

@JsonSerializable()
class GeofenceModel{
  int? id = 0;
  String? vehicId;
  String? orderId;
  String? allocId;
  String? allocState;
  String lat;      // 뽑아올때 double로 변환시켜야함
  String lon;      // 뽑아올때 double로 변환시켜야함
  String? endDate;
  String? flag;
  int? stopNum;

  GeofenceModel({
    this.vehicId,
    this.orderId,
    this.allocId,
    this.allocState,
    required this.lat,
    required this.lon,
    this.endDate,
    this.flag,
    this.stopNum
  });

  factory GeofenceModel.fromJSON(Map<String,dynamic> json) => _$GeofenceModelFromJson(json);
  factory GeofenceModel.fromMap(Map<String,dynamic> map) {
    return GeofenceModel(
        vehicId:map["vehicId"],
        orderId:map["orderId"],
        allocId:map["allocId"],
        allocState:map["allocState"],
        lat:map["lat"],
        lon:map["lon"],
        endDate:map["endDate"],
        flag:map["flag"],
        stopNum:map["stopNum"],
    );
  }

  Map<String,dynamic> toJson() => _$GeofenceModelToJson(this);
  Map<String,dynamic> toMap() {
    return <String,dynamic>{
      "vehicId":vehicId,
      "orderId":orderId,
      "allocId":allocId,
      "allocState":allocState,
      "lat":double.parse(lat??""),
      "lon":double.parse(lon??""),
      "endDate":endDate,
      "flag":flag,
      "stopNum":stopNum,
    };
  }

}