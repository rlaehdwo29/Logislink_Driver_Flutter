import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/model/notice_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/page/subPage/appbar_notice_detail_page.dart';
import 'package:logislink_driver_flutter/provider/appbar_service.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class AppBarNoticePage extends StatefulWidget {
  _AppBarNoticePageState createState() => _AppBarNoticePageState();
}

class _AppBarNoticePageState extends State<AppBarNoticePage> {
  final controller = Get.find<App>();
  ProgressDialog? pr;

  final mList = List.empty(growable: true).obs;

  Widget getListView(NoticeModel item) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => AppBarNoticeDetailPage(item)));
      },
        child: Container(
      padding: EdgeInsets.fromLTRB(CustomStyle.getWidth(20.0), CustomStyle.getHeight(10.0), CustomStyle.getWidth(20.0), CustomStyle.getWidth(10.0)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.0,
            color: line
          )
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              "${Util.getDateStrToStr(item.regdate, "yyyy-MM-dd")}",
            style: CustomStyle.CustomFont(styleFontSize12, text_color_03),
          ),
          Container(
            padding: EdgeInsets.only(top: CustomStyle.getHeight(5.0)),
            child: Text(
              "${item.title}",
              style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
            ),
          ),
        ],
      ),
        )
    );
  }

  Widget getNoticeListWidget() {
    return mList.isNotEmpty
            ? SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  mList.length,
                      (index) {
                    var item = mList[index];
                    return getListView(item);
                  },
                )))
            : SizedBox(
          child: Center(
              child: Text(
                Strings.of(context)?.get("empty_list") ?? "Not Found",
                style: CustomStyle.CustomFont(styleFontSize20, styleBlackCol1),
              )),
        );
  }

  Widget getNoticeFuture() {
    final appBarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
      future: appBarService.getNotice(
        context
      ),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(mList.isNotEmpty) mList.clear();
          mList.value.addAll(snapshot.data);
          return getNoticeListWidget();
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

  @override
  Widget build(BuildContext context) {
    pr = Util.networkProgress(context);
    return Scaffold(
      backgroundColor: styleWhiteCol,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
          child: AppBar(
            centerTitle: true,
            title: Text(
                "공지사항",
                style: CustomStyle.appBarTitleFont(
                    styleFontSize16, styleWhiteCol)),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: styleWhiteCol,
              icon: const Icon(Icons.arrow_back),
            ),
          )),
      body: SafeArea(
          child: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: getNoticeFuture(),
                )
            )
      ),
    );
  }
  
}