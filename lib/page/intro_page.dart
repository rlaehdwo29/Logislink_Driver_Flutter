import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_main_widget.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/geofence_model.dart';
import 'package:logislink_driver_flutter/common/model/version_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/db/appdatabase.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:dio/dio.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class IntroPage extends StatefulWidget {

  const IntroPage({Key? key}):super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();

}

class _IntroPageState  extends State<IntroPage> with CommonMainWidget {

  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      checkFinishGeofence();
      checkVersion();
      /*if(checkPermission()){
        showPermissionDialog();
      }else{
        checkVersion();
      }*/
    });

  }

  Future<void> checkFinishGeofence() async {
    AppDataBase db = App().getRepository();
    List<GeofenceModel>? list = await db.getFinishGeofence();
    if(list != null && list.length != 0) {
      db.deleteAll(list);
    }
  }

  Future<void> checkVersion() async {
    Logger logger = Logger();
    await pr?.show();
    await DioService.dioClient(header: true).getVersion("D").then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("checkVersion() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        var list;
        try{
          list = _response.resultMap?["data"] as List;
        }catch(e) {
          print(e);
        }

        if(list != null && list.isNotEmpty) {
          VersionModel? codeVersion = VersionModel.fromJSON(list[1]);
          if(SP.get(Const.CD_VERSION) != codeVersion.versionCode) {
            SP.putString(Const.CD_VERSION, codeVersion.versionCode ?? "");
            GetCodeTask();
          }
        }else{
          //showNotDetail();
        }

      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("intro_page.dart checkVersion() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("intro_page.dart checkVersion() Error Default:");
          break;
      }
    });
  }

  Future<void> GetCodeTask() async {
    Logger logger = Logger();
    List<String> codeList = Const.getCodeList();
    await pr?.show();
    for(String code in codeList){
      await DioService.dioClient(header: true).getCodeList(code).then((it){
        ReturnMap _response = DioService.dioResponse(it);
        logger.d("GetCodeTask() _response -> ${_response.status} // ${_response.resultMap}");
        if(_response.status == "200") {
          if(_response.resultMap?["data"] != null) {
            var jsonString = jsonEncode(it.response.data);
              SP.putCodeList(code, jsonString);
          }
        }
      }).catchError((Object obj) async {
        await pr?.hide();
        switch (obj.runtimeType) {
          case DioError:
          // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            logger.e("intro_page.dart GetCodeTask() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
            openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
            break;
          default:
            logger.e("intro_page.dart GetCodeTask() Error Default:");
            break;
        }
      });
    }
    await pr?.hide();
  }

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return mainWidget(
        context,
        child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
            body: SafeArea(
              child: Center(
                child: Image.asset(
                    "assets/image/ic_icon.png",
                ),
              )
            )
        )
    );
  }


}