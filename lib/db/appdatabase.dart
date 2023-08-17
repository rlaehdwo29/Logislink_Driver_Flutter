import 'package:get/get.dart';
import 'package:logislink_driver_flutter/common/model/geofence_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//Table
final String geofenceTable = "geofence";
// Column
final String geo_id = "id";
final String geo_vehicId = "vehicId";
final String geo_orderId = "orderId";
final String geo_allocId = "allocId";
final String geo_allocState = "allocState";
final String geo_lat = "lat";
final String geo_lon = "lon";
final String geo_endDate = "endDate";
final String geo_flag = "flag";
final String geo_stopNum = "stopNum";

class AppDataBase {

  static Database? _geoFenceDb;

  Future<Database?> get geoFenceDb async {
    _geoFenceDb = await initGeoDB();
    return _geoFenceDb;
  }

  Future initGeoDB() async {
    String path = join(await getDatabasesPath(), 'geofence.db');
    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute("CREATE TABLE $geofenceTable($geo_id integer primary key autoincrement, $geo_vehicId text, $geo_orderId text, $geo_allocId text, $geo_allocState text, $geo_lat text, $geo_lon text, $geo_endDate text, $geo_flag text, $geo_stopNum integer)");
        }
    );
  }

  Future setGeofence(GeofenceModel geo) async {
      final db = await geoFenceDb;
      try {
        final List<Map<String, Object?>>? maps = await db?.query(
            '$geofenceTable', where: "$geo_id = ?", whereArgs: [geo.id]);
        if (maps == null || maps.length <= 0) {
          await db?.insert(geofenceTable, geo.toMap());
        } else {
          await db?.update('$geofenceTable', <String, dynamic>{
            "$geo_vehicId": "${geo.vehicId}",
            "$geo_orderId": "${geo.orderId}",
            "$geo_allocId": "${geo.allocId}",
            "${geo_allocState}": "${geo.allocState}",
            "${geo_lat}": "${geo.lat}",
            "${geo_lon}": "${geo.lon}",
            "${geo_endDate}": "${geo.endDate}",
            "${geo_flag}": "${geo.flag}",
            "${geo_stopNum}": geo.stopNum
          }, where: "$geo_id = ?", whereArgs: [geo.id]);
        }
      }catch(e){
        print("setGeofence() Exception => $e");
      }
  }

  Future delete(GeofenceModel order) async {
    final db = await geoFenceDb;
    await db?.delete('$geofenceTable',where: "$geo_id =?",whereArgs: [order.id]);
  }

  Future<void> deleteAll(List<GeofenceModel> order) async {
    final db = await geoFenceDb;
    await db?.execute("DROP TABLE $geofenceTable");
    await db?.execute("CREATE TABLE $geofenceTable($geo_id integer primary key autoincrement, $geo_vehicId text, $geo_orderId text, $geo_allocId text, $geo_allocState text, $geo_lat text, $geo_lon text, $geo_endDate text, $geo_flag text, $geo_stopNum integer)");
  }

  Future deleteGeoFence(String? vehicId, String? orderId, String? allocState, int? stopNum ) async {
    final db = await geoFenceDb;
    await db?.delete('$geofenceTable',where: "$geo_vehicId = ? and $geo_orderId =? and $geo_allocState = ? and $geo_stopNum = ?" ,
    whereArgs: [vehicId, orderId, allocState, stopNum]);
  }
  
  Future clear() async {
    final db = await geoFenceDb;
    await db?.delete('$geofenceTable');
  }

  Future<List<GeofenceModel>> getAllGeoFenceList(String? vehicId) async {
    List<GeofenceModel> geoList = List.empty(growable: true);
    final db = await geoFenceDb;
    try {
      var result = await db?.rawQuery(
          "SELECT * FROM $geofenceTable WHERE $geo_vehicId = ?", [vehicId]);
      if (result != null && result.length > 0) {
        List<GeofenceModel> itemsList = result.map((i) =>
            GeofenceModel.fromJSON(i)).toList();
        if (geoList.isNotEmpty == true) geoList = List.empty(growable: true);
        geoList.addAll(itemsList);
      }
    }catch(e) {
      print("getAllGeoFenceList() Exepction => $e ");
    }
    return geoList;
  }

  Future<GeofenceModel?> getGeoFence(String? vehicId, int? id) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_id = ?",[vehicId,id]);
    if(result == null || result.length <= 0){
      return null;
    }else{
      return GeofenceModel.fromMap(result![0]);
    }
  }

  Future getRemoveGeoList(String? vehicId, String? orderId) async {
    final db = await geoFenceDb;
    await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ?",[vehicId,orderId]);
  }

  Future<GeofenceModel?> getRemoveGeo(String? vehicId, String? orderId, String? allocState) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ? and $geo_allocState = ?",[vehicId,orderId,allocState]);
    if(result == null || result.length <= 0){
      return null;
    }else{
      return GeofenceModel.fromMap(result![0]);
    }
  }

  Future<GeofenceModel?> getRemoveGeoSEP(String? vehicId, String? orderId, String? allocState, int? stopNum) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ? and $geo_allocState = ? and $geo_stopNum = ?",[vehicId,orderId,allocState,stopNum]);
    if(result == null || result.length <= 0){
      return null;
    }else{
      return GeofenceModel.fromMap(result![0]);
    }
  }

  Future<int?> checkGeo(String? vehicId, String? orderId) async {
    final db = await geoFenceDb;
    var result = await db?.query("select exists ( select * from $geofenceTable where $geo_vehicId = ($vehicId) and $geo_orderId = ($orderId) ) ");
    if(result!.length > 0) {
      return 1;
    }else{
      return 0;
    }
  }

  Future<int?> checkGeoP(String? vehicId, String? orderId, int? stopNum) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ? and $geo_stopNum = ?",[vehicId,orderId,stopNum]);
    if(result == null || result.length <= 0) {
      return 0;
    }else{
      return 1;
    }
  }

  Future<int?> checkGeoSP(String? vehicId, String? orderId, int? stopNum) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ? and $geo_allocState = ? and $geo_stopNum = ?",[vehicId,orderId,"SP",stopNum]);
    if(result == null || result.length <= 0) {
      return 0;
    }else{
      return 1;
    }
  }

  Future<int?> checkGeoEP(String? vehicId, String? orderId, int? stopNum) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ? and $geo_allocState = ? and $geo_stopNum = ?",[vehicId,orderId,"EP",stopNum]);
    if(result == null || result.length <= 0) {
      return 0;
    }else{
      return 1;
    }
  }

  Future<bool?> checkPointGeo(String? vehicId, String? orderId) async {
    final db = await geoFenceDb;
    var result = await db?.query("select exists ( select * from $geofenceTable where $geo_vehicId = ($vehicId) and $geo_orderId = ($orderId) and $geo_allocState = P )");
    if(result!.length > 0) {
      return true;
    }else{
      return false;
    }
  }

  Future<bool?> checkSPointGeo(String? vehicId, String? orderId, int? stopNum) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT EXISTS ( SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ? and $geo_allocState = ? and $geo_stopNum = ? )",[vehicId,orderId,"SP",stopNum]);
    if(result == null || result.length <= 0){
      return false;
    }else{
      return true;
    }
  }

  Future<bool?> checkEPointGeo(String? vehicId, String? orderId, int? stopNum) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT EXISTS ( SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ? and $geo_allocState = ? and $geo_stopNum = ? )",[vehicId,orderId,"EP",stopNum]);
    print("checkEPointGeo() result => $result");
    if(result == null || result.length <= 0){
      return false;
    }else{
      return true;
    }
  }

  Future<int?> checkGeoE(String? vehicId, String? orderId) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ? and $geo_allocState = ?",[vehicId,orderId,"E"]);
      if (result == null || result.length <= 0) {
        return 0;
      } else {
        return 1;
      }
  }

  Future<int?> checkGeoS(String? vehicId, String? orderId) async {
    final db = await geoFenceDb;
    var result = await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_vehicId = ? and $geo_orderId = ? and $geo_allocState = ?",[vehicId,orderId,"S"]);
      if (result == null || result.length <= 0) {
        return 0;
      } else {
        return 1;
      }
  }

  Future<int?> checkStartGeo(String? vehicId, String? orderId) async {
    final db = await geoFenceDb;
    var result = await db?.query("select exists ( select * from $geofenceTable where $geo_vehicId = ($vehicId) and $geo_orderId = ($orderId) and $geo_allocState = S )");
    if(result == null || result.length <= 0) {
      return 0;
    }else{
      return 1;
    }
  }

  Future<int?> checkEndGeo(String? vehicId, String? orderId) async {
    final db = await geoFenceDb;
    var result = await db?.query("select exists ( select * from $geofenceTable where $geo_vehicId = ($vehicId) and $geo_orderId = ($orderId) and $geo_allocState = E )");
    if(result!.length > 0) {
     return 1;
    }else {
      return 0;
    }
  }

  Future<List<GeofenceModel>?> getFinishGeofence() async {
    final db = await geoFenceDb;
    List<GeofenceModel> geoList = List.empty(growable: true);
    try {
      var result = await db?.rawQuery("SELECT * FROM $geofenceTable WHERE $geo_endDate > ?", [DateTime.now().toLocal().toString()]);
      if (result != null && result.length > 0) {
        List<GeofenceModel> itemsList = result.map((i) =>
            GeofenceModel.fromJSON(i)).toList();
        if (geoList.isNotEmpty == true) geoList = List.empty(growable: true);
        geoList.addAll(itemsList);
      }
    }catch(e) {
     print("getFinishGeofence() => $e");
    }
      return geoList;
  }

}