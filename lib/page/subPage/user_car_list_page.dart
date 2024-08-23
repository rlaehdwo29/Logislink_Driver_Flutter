import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/provider/user_car_service.dart';
import 'package:provider/provider.dart';

class UserCarListPage extends StatefulWidget {

  UserCarListPage({Key? key}): super(key: key);

  _UserCarListPageState createState() => _UserCarListPageState();

}

class _UserCarListPageState extends State<UserCarListPage> {

  final controller = Get.find<App>();
  final userCarList = List.empty(growable: true).obs;

  Widget getUserCarInfoFuture() {
    final userCarService = Provider.of<UserCarInfoService>(context);
    return FutureBuilder(
        future: userCarService.getUserCarInfo(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            if(userCarList.isNotEmpty) userCarList.clear();
            userCarList.value.addAll(snapshot.data);
            return getUserCarInfoListItem();
          }else if(snapshot.hasError) {
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
        });
  }

  Widget getUserCarInfoListItem() {
    return Obx((){
      return Expanded(
          child: userCarList.isNotEmpty ?
          SingleChildScrollView(
              child: Column(
                  children: List.generate(userCarList.value.length, (index) {
                    var item = userCarList[index];
                    return InkWell(
                        onTap: () async {
                          UserModel? user = await controller.getUserInfo();
                          user?.vehicId = item.vehicId;
                          controller.setUserInfo(user!);

                          Navigator.of(context).pop({'code': 200});
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: CustomStyle.getHeight(10.0),
                                  horizontal: CustomStyle.getWidth(20.0)),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text("${item.carNum}",
                                      style: CustomStyle.CustomFont(
                                          styleFontSize14,
                                          text_color_01)),
                                  Container(
                                      padding: EdgeInsets.only(
                                          top:
                                          CustomStyle.getHeight(5.0)),
                                      child: Row(children: [
                                        Text(
                                          "${item.carTonName}",
                                          style: CustomStyle.CustomFont(
                                              styleFontSize12,
                                              text_color_03),
                                        ),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left:
                                                CustomStyle.getWidth(
                                                    5.0)),
                                            child: Text(
                                              "${item.carTypeName}",
                                              style:
                                              CustomStyle.CustomFont(
                                                  styleFontSize12,
                                                  text_color_03),
                                            ))
                                      ]))
                                ],
                              ),
                            ),
                            CustomStyle.getDivider2(),
                          ],
                        ));
                  }
                  )
              )
          ):const SizedBox()
      );
    });
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.white,
     appBar: PreferredSize(
       preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
       child: AppBar(
         title: Text(
             Strings.of(context)?.get("car_num")??"Not Found",
             style: CustomStyle.appBarTitleFont(styleFontSize16,styleWhiteCol)
         ),
         centerTitle: true,
         automaticallyImplyLeading: false,
         actions: [],
         leading: IconButton(
           onPressed: (){
            Navigator.pop(context);
           },
           color: styleWhiteCol,
           icon: const Icon(Icons.arrow_back),
         ),
       )
     ),
     body: SafeArea(
       child: Container(
             child: Column(
             children :[
               Container(
                   padding: const EdgeInsets.all(10.0),
                   child: Text(
                     "${Strings.of(context)?.get("user_car_info")}",
                     style: CustomStyle.baseFont(),
                   )
               ),
               CustomStyle.getDivider2(),
               getUserCarInfoFuture()
              ]
             )
         )
     ),
   );
  }

}