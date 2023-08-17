import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/notification_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/page/subPage/order_detail_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/provider/notification_service.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {

  NotificationPage({Key? key}):super(key: key);

  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  final controller = Get.find<App>();
  final mList = List.empty(growable: true).obs;

  ProgressDialog? pr;

  @override
  void initState() {
    getNotification();
    super.initState();
  }

  Future<void> getNotification() async {
    Logger logger = Logger();
    UserModel? user = controller.getUserInfo();
    await pr?.show();
    await DioService.dioClient(header: true).getNotification(user?.authorization).then((it) async {
      await pr?.hide();
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("getNotification() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["result"] == true) {
            var list = _response.resultMap?["data"] as List;
            List<NotificationModel> itemsList = list.map((i) => NotificationModel.fromJSON(i)).toList();
            if (mList.isNotEmpty == true) mList.value = List.empty(growable: true);
            mList.value?.addAll(itemsList);
        } else {
          mList.value = List.empty(growable: true);
          openOkBox(context, _response.resultMap?["msg"], Strings.of(context)?.get("close") ?? "Not Found", () => Navigator.of(context).pop(false));
        }
      }else{
        Util.toast(_response.message);
      }

    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("notification_page.dart getNotification() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("notification_page.dart getNotification() Error Default:");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
            child: AppBar(
              centerTitle: true,
              title: Text("알림",
                  style: CustomStyle.appBarTitleFont(
                      styleFontSize18, styleWhiteCol)),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: styleWhiteCol,
                icon: const Icon(Icons.arrow_back),
              ),
            )),
        body: SafeArea(
            child: Obx(() {
          return Container(
              child: itemListFuture()
          );
        })));
  }

  Widget getNotificationListWidget() {
    return mList.isNotEmpty
            ? SingleChildScrollView(
          child: Flex(
              direction: Axis.vertical,
              children: List.generate(
                mList.length,
                    (index) {
                  var item = mList[index];
                  return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailPage(allocId: item.allocId)));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: line, width: CustomStyle.getWidth(0.5)
                            )
                          )
                        ),
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.title,
                                    style: CustomStyle.CustomFont(
                                        styleFontSize14, text_color_01,
                                        font_weight: FontWeight.w600),
                                  ),
                                  Text(
                                    item.contents,
                                    style: CustomStyle.CustomFont(
                                        styleFontSize12, text_color_02),
                                  ),
                                  Text(
                                    "${Util.getDateStrToStr(item.sendDate, "yyyy-MM-dd")}",
                                    style: CustomStyle.CustomFont(
                                        styleFontSize10, text_color_03),
                                  )
                                ],
                              )
                              ),
                              Expanded(
                                flex: 1,
                               child: Icon(Icons.arrow_forward_ios_outlined, size: 24, color: Colors.grey)
                              )
                            ],
                          )));
                },
              )),
        )
            : SizedBox(
          child: Center(
              child: Text(
                Strings.of(context)?.get("empty_list") ?? "Not Found",
                style:
                CustomStyle.CustomFont(styleFontSize20, styleBlackCol1),
              )),
    );
  }

  Widget itemListFuture() {
    final notificationService = Provider.of<NotificationService>(context);
    return FutureBuilder(
      future: notificationService.getNotification(context, controller.getUserInfo()?.authorization),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(mList.isNotEmpty) mList.clear();
            mList.value.addAll(snapshot.data);
          return getNotificationListWidget();
        }else if(snapshot.hasError){
          return Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(40.0)),
            alignment: Alignment.center,
            child: Text(
                "${Strings.of(context)?.get("empty_list")}",
                style: CustomStyle.baseFont()),
          );
        }
        return Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            backgroundColor: styleGreyCol1,
          ),
        );
      },
    );
  }

}