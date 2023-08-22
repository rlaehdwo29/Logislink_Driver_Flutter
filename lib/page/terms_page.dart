import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logislink_driver_flutter/common/common_main_widget.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({Key? key}) : super(key:key);

  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
            child: Obx(() {
              return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset("assets/image/ic_top_logo.png"),

                    ],
                  )
              );
            })));
  }

}
