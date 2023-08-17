import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logislink_driver_flutter/common/collapsing_list_tile.dart';
import 'package:logislink_driver_flutter/common/strings.dart';
import 'package:logislink_driver_flutter/common/style_theme.dart';

import 'model/user_model.dart';

class MenuPopup extends StatefulWidget {
  MenuPopup({Key? key,this.title,this.userInfo}) : super(key: key);

  final String? title;
  final UserModel? userInfo;

  @override
  _MenuPopupState createState() => _MenuPopupState();
}
class _MenuPopupState extends State<MenuPopup> {

  Widget _menu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CollapsingListTile(
          title: Strings.of(context)?.get('close')??"Not Found",
          icon: Icons.close,
          selectedMenu: widget.title??"Not Found",
          onTapEvent: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

   /* return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
              accountName: Text(widget.userInfo?.driverName??"Null"),
              accountEmail: Text(widget.userInfo?.carNum??"Null1")
          ),
        ],
      ),
    );*/

    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: CustomStyle.getWidth(60.0),
            height: _height,
            color: main_color,
          ),
          Positioned(
            top: CustomStyle.getHeight(0.0),
            right: 0,
            child: _menu(),
          ),
          Positioned(
            right: 0,
            bottom: CustomStyle.getHeight(10.0),
            child: CollapsingListTile(
              title: Strings.of(context)?.get('setting')??"Not Found",
              icon: Icons.settings,
              selectedMenu: widget.title??"Not Found",
              onTapEvent: () {
                Navigator.of(context).pop();
                //Navigator.pushReplacement(context, FadeRoute(page: ConfigPage()));
              },
            ),
          ),
        ],
      ),
    );
  }

}