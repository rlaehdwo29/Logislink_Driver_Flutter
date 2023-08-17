import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logislink_driver_flutter/common/model/code_model.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';
import 'package:logislink_driver_flutter/constants/const.dart';
import 'package:logislink_driver_flutter/utils/sp.dart';
import 'package:logislink_driver_flutter/widget/show_bank_check_widget.dart';

class ShowSelectDialogWidget {
  final BuildContext context;
  final String mTitle;
  final String codeType;
  final int? value;
  final void Function(CodeModel,{String codeType,int value}) callback;

  ShowSelectDialogWidget({required this.context, required this.mTitle, required this.codeType,this.value, required this.callback});

  Future<void> showDialog() {
    List<CodeModel>? mList = SP.getCodeList(codeType);
    if (codeType == Const.ORDER_STATE_CD) {
      mList?.insert(0, CodeModel(code: "", codeName: "전체"));
    }
    if (codeType == Const.YN_SEL) {
      mList = List.empty(growable: true);
      mList.add(CodeModel(code: "Y", codeName: "가능"));
      mList.add(CodeModel(code: "N", codeName: "불가"));
    }

    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              mTitle,
              style: CustomStyle.CustomFont(styleFontSize18, Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, size: 30)
              )
            ],
            automaticallyImplyLeading: false,
          ),
          body: GridView.builder(
              itemCount: mList?.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                childAspectRatio: (1 / .65),
                mainAxisSpacing: 2, //수평 Padding
                crossAxisSpacing: 2, //수직 Padding
              ),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    onTap: () {
                      callback(mList![index],codeType: codeType, value: value??0);
                      Navigator.pop(context);
                    },
                    child: Container(
                        height: CustomStyle.getHeight(70.0),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                ),
                                right: BorderSide(
                                    color: line,
                                    width: CustomStyle.getWidth(1.0)
                                )
                            )
                        ),
                        child: Center(
                          child: Text(
                            "${mList?[index].codeName}",
                            textAlign: TextAlign.center,
                            style: CustomStyle.CustomFont(
                                styleFontSize12, text_color_01,
                                font_weight: FontWeight.w600),
                          ),
                        )
                    )
                );
              }
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: "Barrier",
      barrierColor: Colors.white,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }
}