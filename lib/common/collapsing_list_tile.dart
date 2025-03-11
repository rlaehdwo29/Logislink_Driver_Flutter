import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'style_theme.dart';

class CollapsingListTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final Image? image;
  final Image? image2;
  final String selectedMenu;
  Function()? onTapEvent;

  CollapsingListTile({required this.title, required this.icon, required this.selectedMenu,this.onTapEvent,this.image,this.image2});

  @override
  _CollapsingListTileState createState() => _CollapsingListTileState();

}

class _CollapsingListTileState extends State<CollapsingListTile>{
  @override
  Widget build(BuildContext context) {
    return InkWell(

      onTap:
      (widget.title == widget.selectedMenu) ? () => {} : widget.onTapEvent,
      child: (widget.title == widget.selectedMenu)
          ? Container(
        width: CustomStyle.getWidth(30.0) +
            CustomStyle.getWidth(20.0) +
            CustomStyle.getWidth(20.0) +
            (CustomStyle.getWidth(8.0) * widget.title.length),
        height: CustomStyle.getHeight(50.0),
        margin: EdgeInsets.only(right: CustomStyle.getWidth(16.0)),
        padding:
        EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(15.0)),
        decoration: CustomStyle.baseBoxDecoSub(),
        child: Row(
          children: <Widget>[
            widget.image != null
                ? widget.image!
                : Icon(widget.icon,
                color: styleBaseCol1,
                size: CustomStyle.getWidth(26.0)),
            CustomStyle.sizedBoxWidth(10.0),
            Expanded(
              child: Text(
                widget.title,
                style: CustomStyle.baseColFont(),
              ),
            ),
          ],
        ),
      )
          : Container(
        margin: EdgeInsets.symmetric(
            horizontal: CustomStyle.getWidth(20.0),
            vertical: CustomStyle.getHeight(18.0)),
        child: Row(
          children: <Widget>[
            widget.image2 != null
                ? widget.image2!
                : Icon(widget.icon,
                color: styleWhiteCol,
                size: CustomStyle.getWidth(26.0)),
          ],
        ),
      ),

    );
  }
}