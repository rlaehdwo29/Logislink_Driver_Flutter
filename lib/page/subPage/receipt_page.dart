import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:logislink_driver_flutter/common/app.dart';
import 'package:logislink_driver_flutter/common/common_util.dart';
import 'package:logislink_driver_flutter/common/config_url.dart';
import 'package:logislink_driver_flutter/common/model/order_model.dart';
import 'package:logislink_driver_flutter/common/model/receipt_model.dart';
import 'package:logislink_driver_flutter/common/model/user_model.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/page/subPage/receipt_detail_page.dart';
import 'package:logislink_driver_flutter/provider/dio_service.dart';
import 'package:logislink_driver_flutter/provider/receipt_service.dart';
import 'package:logislink_driver_flutter/utils/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../constants/custom_log_interceptor.dart';

class ReceiptPage extends StatefulWidget{
  OrderModel? item;

  ReceiptPage({Key? key,this.item}):super(key: key);

  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage>{
  final controller = Get.find<App>();
  final receiptList = List.empty(growable: true).obs;
  final ImagePicker? _picker = ImagePicker();
  dynamic _pickImageError;
  final _mediaFileList = List.empty(growable: true).obs;
  ProgressDialog? pr;

  Future<void> _displayPickImageDialog(BuildContext context, OnPickImageCallback onPick) async {
    return onPick(null, null, null);
  }

  void onRemoveItem(int index) {
    if(receiptList.length < 2) {
      Util.toast("새로운 인수증 추가 후 삭제해주세요");
      return;
    }

    openCommonConfirmBox(
        context,
        "해당 인수증을 삭제하시겠습니까?",
        Strings.of(context)?.get("cancel")??"Not Found",
        Strings.of(context)?.get("confirm")??"Not Found",
            () => Navigator.of(context).pop(false),
            () async {
          Navigator.of(context).pop(false);
          removeReceipt(receiptList?[index].fileSeq);
        });

  }

  Future<void> removeReceipt(int fileSeq) async {
    Logger logger = Logger();
    UserModel user = controller.getUserInfo()!;
    await DioService.dioClient(header: true).removeReceipt(user.authorization, widget.item?.orderId, widget.item?.allocId, fileSeq).then((it) async {
      ReturnMap _response = DioService.dioResponse(it);
      await pr?.hide();
      logger.d("removeReceipt() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        Util.toast("인수증을 삭제했습니다.");
        setState(() {

        });
      }else{
        Util.toast(_response.message);
      }
    }).catchError((Object obj) async {
      await pr?.hide();
      switch (obj.runtimeType) {
        case DioError:
        // 's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          logger.e("receipt_page.dart removeReceipt() Error Default: ${res?.statusCode} -> ${res?.statusMessage}");
          openOkBox(context,"${res?.statusCode} / ${res?.statusMessage}",Strings.of(context)?.get("confirm")??"Error!!",() {Navigator.of(context).pop(false);});
          break;
        default:
          logger.e("receipt_page.dart removeReceipt() Error Default:");
          break;
      }
    });
  }

  /*Map<String,dynamic> createPartFromString(String descriptionString) {
    var map = {
      "$descriptionString" : MediaType()
    };
    return map;
  }*/

  Future<void> compressImage(XFile file) async {
    await uploadReceipt(file);
  }

  Future<void> uploadReceipt(XFile? file) async {
      UserModel? user = controller.getUserInfo();

      var _formatFile = File(file!.path);
        var request = http.MultipartRequest(
            "POST", Uri.parse(SERVER_URL + URL_RECEIPT_UPLOAD));
        request.headers.addAll({"Authorization": '${user?.authorization}'});
        request.fields['orderId'] = '${widget.item?.orderId}';
        request.fields['allocId'] = '${widget.item?.allocId}';
        request.fields['fileTypeCode'] = 'I';
        //request.files.add(http.MultipartFile.fromString('uploadFile', file!.path));
        request.files.add(await http.MultipartFile.fromPath('uploadFile', _formatFile!.path, contentType: MediaType.parse("multipart/form-data"))); // 이게 업로드 됨.

        var response = await request.send();
        if (response.statusCode == 200) {
          var jsonBody = json.decode(await response.stream.bytesToString()); // json 응답 값을 decode
          print("uploadReceipt() Result ToJson => ${jsonBody} // ${jsonBody["result"]} ${jsonBody["msg"]}");
          if(jsonBody["result"] == true) {
            await getReceiptList();
            setState(() {});
          }else{
            Util.toast("${jsonBody["msg"]}");
          }
        } else {
          Util.toast(Strings.of(context)?.get("error_message"));
        }
  }

  Future<void> showAlbum() async {
    await _displayPickImageDialog(context,
        (double? maxWidth, double? maxHeight, int? quality) async {
      try {
        final XFile? pickedFile = await _picker?.pickImage(
          source: ImageSource.gallery,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: 50,
        ).then((file) {
          if (file == null) return null;
          setState(() async {
            //getImageDate(pickedFile?.path);
            await compressImage(file);
          });

        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    });
  }

  Future<void> checkPermission() async {
    if (await Permission.contacts.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      print("연결");
    }else{
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      final permissionStatus = await Permission.manageExternalStorage.status;

      if(permissionStatus != PermissionStatus.granted) {
        if (permissionStatus.isPermanentlyDenied) {
          await openAppSettings();
        }else{
          await Permission.storage.request();
        }
      }else{
        await showAlbum();
      }
    }
  }

  Future<void> getReceiptList () async {
    Logger logger = Logger();
    receiptList.value = List.empty(growable: true);
    await DioService.dioClient(header: true).getReceipt(App().getUserInfo().authorization,  widget.item?.orderId).then((it) {
      ReturnMap _response = DioService.dioResponse(it);
      logger.d("receipt_page.dart getReceipt() _response -> ${_response.status} // ${_response.resultMap}");
      if(_response.status == "200") {
        if (_response.resultMap?["data"] != null) {
          var list = _response.resultMap?["data"] as List;
          List<ReceiptModel> itemsList = list.map((i) => ReceiptModel.fromJSON(i)).toList();
          receiptList?.addAll(itemsList);
        }
      }else{
        receiptList.value = List.empty(growable: true);
      }
    }).catchError((Object obj){
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          print("receipt_page.dart getReceipt() Error => ${res?.statusCode} // ${res?.statusMessage}");
          break;
        default:
          print("receipt_page.dart getReceipt() Error Default => ");
          break;
      }
    });
  }

  Widget getReceipt() {
    return Expanded(
        child: receiptList.isNotEmpty ? Container(
            padding: const EdgeInsets.all(5.0),
            color: order_item_background,
            child: GridView.builder(
              itemCount: receiptList.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                childAspectRatio: (1 / .90),
                mainAxisSpacing: 8, //수평 Padding
                crossAxisSpacing: 8, //수직 Padding
              ),
              itemBuilder: (BuildContext context, int index) {
                var filename =
                    SERVER_URL + RECEIPT_PATH + receiptList?[index].fileName;
                return Stack(
                    fit: StackFit.expand,
                    children: [
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ReceiptDetailPage(item: receiptList[index])
                      ));
                    },
                  child: Image.network(
                    filename,
                    fit: BoxFit.cover,
                  )
                ),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                          onPressed: () {
                            onRemoveItem(index);
                          },
                          icon: const Icon(Icons.cancel, size: 24)
                      )
                  )
                ]);
              },
            )) : const SizedBox()
    );
  }

  Widget getReceiptFuture() {
    final receiptService = Provider.of<ReceiptService>(context);
    return FutureBuilder(
        future: receiptService.getReceipt(context, controller.getUserInfo()?.authorization, widget.item?.orderId),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            print("getReceiptFuture() has Data! => ${snapshot.data}");
              if(receiptList.isNotEmpty) receiptList.value = List.empty(growable: true);
              receiptList.addAll(snapshot.data);
              for(var receiptItem in receiptList){
                  XFile _xFile = XFile(receiptItem.filePath,name: receiptItem.fileName);
              }
              return getReceipt();
          } else if(snapshot.hasError) {
            print("getReceiptFuture() Error! => ${snapshot.error}");
            return Container();
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
    pr = Util.networkProgress(context);
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({'code':200});
          return false;
    } ,
    child: Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(CustomStyle.getHeight(50.0)),
          child: AppBar(
            centerTitle: true,
            title: Text(
                Strings.of(context)?.get("receipt")??"Not Found",
                style: CustomStyle.appBarTitleFont(styleFontSize18,styleWhiteCol)
            ),
            leading: IconButton(
              onPressed: (){
                Navigator.of(context).pop({'code':200});
              },
              color: styleWhiteCol,
              icon: const Icon(Icons.arrow_back),
            ),
          )
      ),
      body: SafeArea(
         // child: Obx((){
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: CustomStyle.getHeight(10.0),right: CustomStyle.getWidth(20.0),left: CustomStyle.getWidth(20.0)),
                  child: Text(
                    Strings.of(context)?.get("receipt_info")??"Not Found",
                    style: CustomStyle.CustomFont(styleFontSize14, text_color_01),
                  )
                ),
                Container(
                  padding: EdgeInsets.only(top: CustomStyle.getHeight(5.0),bottom:CustomStyle.getHeight(10.0), right: CustomStyle.getWidth(20.0),left: CustomStyle.getWidth(20.0)),
                  child: Text(
                    Strings.of(context)?.get("receipt_info2")??"Not Found",
                    style: CustomStyle.CustomFont(styleFontSize12, text_color_02),
                  ),
                ),
                getReceiptFuture()
              ],
            )
         // }),
      ),
      bottomNavigationBar: Container(
          height: 60.0,
            color: main_color,
            padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 10.0),
            child: InkWell(
              onTap: () async {
                //checkPermission();
                await showAlbum();
              },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_album_outlined,color: styleWhiteCol,size: 32),
                  CustomStyle.sizedBoxWidth(10.0),
                  Text(
                    "인수증 가져오기",
                    textAlign: TextAlign.center,
                    style: CustomStyle.CustomFont(styleFontSize16, Colors.white),
                  )
                ]
            ),
          )
      ),
    )
    );
  }

}
typedef OnPickImageCallback = void Function(double? maxWidth, double? maxHeight, int? quality);