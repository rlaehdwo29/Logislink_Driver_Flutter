import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/model/juso_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/provider/appbar_service.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

class AddrSearchPage extends StatefulWidget {

  final void Function(String? addr,String? zipNo) callback;

  AddrSearchPage({Key? key,required this.callback}):super(key: key);

  _AddrSearchPageState createState() => _AddrSearchPageState();
}

class _AddrSearchPageState extends State<AddrSearchPage> {

  TextEditingController searchController = TextEditingController();

  final mList = List.empty(growable: true).obs;

  Future<void> getJuso() async {
    if(searchController.text.isEmpty) {
      Util.toast("검색할 주소를 입력해 주세요.");
      return;
    }
    Logger logger = Logger();
    mList.value = List.empty(growable: true);
    await DioService.jusoDioClient(header: false).getJuso(Const.JUSU_KEY,"1","20",searchController.text,"json").then((it) {
      if (mList.isNotEmpty == true) mList.value = List.empty(growable: true);
      mList.value.addAll(DioService.jusoDioResponse(it));
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("getJuso() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("getJuso() Error Default => ");
          break;
      }
    });
  }

  void selectJibun(String? zipNo ,String? roadAddr) {
    widget.callback(zipNo,roadAddr);
    Navigator.of(context).pop();
  }

  void selectRoad(String? zipNo ,String? roadAddr) {
    widget.callback(zipNo,roadAddr);
    Navigator.of(context).pop();
  }

  Widget getAddrListWidget() {
    return Expanded(
        child: mList.isNotEmpty ?
        SingleChildScrollView(
          child:Flex(
            direction: Axis.vertical,
            children: List.generate(
                  mList.length,
                  (index) {
                    var item = mList[index];
                    return InkWell(
                      onTap: (){},
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: line, width: CustomStyle.getWidth(0.5)
                                )
                            )
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${item.zipNo}",
                              style: CustomStyle.CustomFont(styleFontSize14, addr_zip_no),
                            ),
                            InkWell(
                              onTap: (){
                                selectRoad(item.zipNo,item.roadAddr);
                              },
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children :[
                                    Container(
                                    padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                    child: Text(
                                      "도로명",
                                      style: CustomStyle.CustomFont(styleFontSize12, addr_type_text),
                                    )
                                  ),
                                    Expanded(
                                        child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                      child: Text(
                                        "${item.roadAddr}",
                                        overflow: TextOverflow.ellipsis,
                                        style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                      )
                                    )
                                    )
                              ])
                            ),
                            InkWell(
                                onTap: (){
                                  selectJibun(item.zipNo, item.jibunAddr);
                                },
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children :[
                                      Container(
                                          padding: EdgeInsets.symmetric(vertical: CustomStyle.getHeight(5.0)),
                                          child: Text(
                                            "지번",
                                            style: CustomStyle.CustomFont(styleFontSize12, addr_type_text),
                                          )
                                      ),
                                      Expanded(
                                          child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.0)),
                                              child: Text(
                                                "${item.jibunAddr}",
                                                overflow: TextOverflow.ellipsis,
                                                style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                                              )
                                          )
                                      )
                                    ])
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              )
          )
        ): SizedBox(
      child: Center(
          child: Text(
            Strings.of(context)?.get("empty_list") ?? "Not Found",
            style:
            CustomStyle.CustomFont(styleFontSize20, styleBlackCol1),
          )),
        )
    );

  }

  Widget searchWidget() {
    return Container(
        padding: EdgeInsets.fromLTRB(
            CustomStyle.getWidth(10.0),
            CustomStyle.getHeight(15.0),
            CustomStyle.getWidth(10.0),
            CustomStyle.getHeight(15.0)),
        child: Row(children: [
          Expanded(
              flex: 8,
              child: TextField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                style:
                CustomStyle.CustomFont(styleFontSize14, Colors.black),
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textAlignVertical: TextAlignVertical.center,
                controller: searchController,
                decoration: searchController.text.isNotEmpty ? InputDecoration(
                  border: InputBorder.none,
                  hintText: Strings.of(context)?.get("search_info") ?? "Not Found",
                  hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchController.clear();
                    },
                    icon: const Icon(Icons.clear, size: 18,color: Colors.black,),
                  ),
                ) : InputDecoration(
                  border: InputBorder.none,
                  hintText: Strings.of(context)?.get("search_info") ?? "Not Found",
                  hintStyle: CustomStyle.CustomFont(styleFontSize14, text_color_02),
                ),
                onChanged: (bizKindText) {
                  if (bizKindText.isNotEmpty) {
                    searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));
                  } else {

                  }
                  setState(() {});
                },
              )),
          Expanded(
              flex: 1,
              child: IconButton(
                onPressed: (){
                  getJuso();
                },
                icon: const Icon(Icons.search, size: 28,color: Colors.black),
              )
          )
        ]));
  }

  Widget itemListFuture() {
    final appbarService = Provider.of<AppbarService>(context);
    return FutureBuilder(
      future: appbarService.getAddr(context, searchController.text),
        builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(mList.isNotEmpty) mList.clear();
          mList.value.addAll(snapshot.data);
          return getAddrListWidget();
        }else if(snapshot.hasError) {
          return  Container(
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
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(60.0)),
          child: AppBar(
            centerTitle: true,
              title: Text(
                  Strings.of(context)?.get("addr_search_title") ?? "Not Found",
                  style: CustomStyle.appBarTitleFont(
                      styleFontSize18, styleWhiteCol)
              ),
              leading: IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                color: styleWhiteCol,
                icon: Icon(
                    Icons.keyboard_arrow_left, size: 32.w, color: styleWhiteCol),
              ),
            )
      ),
      body: SafeArea(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    searchWidget(),
                    CustomStyle.getDivider1(),
                     itemListFuture()
                  ],
              )
      ));
  }

}