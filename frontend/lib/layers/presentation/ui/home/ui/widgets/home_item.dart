import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../assets/colors/Colors.dart';

class HomeTabItem extends StatelessWidget {
  final Image image;
  final VoidCallback? onClickAction;
  final Color? bgColor;
  final String label;
  final double? size;
  final TextStyle? textStyle;

  const HomeTabItem(
      {super.key,
      required this.image,
      required this.onClickAction,
      this.bgColor = ColorConstants.kPrimaryColor,
      required this.label,
      this.size = 124,
      this.textStyle});

  const HomeTabItem.mobile(
      {super.key,
      required this.image,
      required this.onClickAction,
      this.bgColor = ColorConstants.kPrimaryColor,
      required this.label,
      this.size = 52,
      this.textStyle});

  static HomeTabItem getHomeTabItem({
    required BuildContext context,
    required Image image,
    VoidCallback? onClickAction,
    Color? bgColor = ColorConstants.kPrimaryColor,
    required String label,
    TextStyle? textStyle
}
      ) {
    if (context.isWide) {
      return HomeTabItem(
          image: image, onClickAction: onClickAction, label: label, textStyle: textStyle, bgColor: bgColor,);
    } else {
      return HomeTabItem.mobile(
          image: image, onClickAction: onClickAction, label: label, textStyle: textStyle, bgColor: bgColor);
    }
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: size! + 40,
      child: Column(
        children: [
          Card(
              elevation: 3,
              color: bgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size! / 4)),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: onClickAction,
                child: Container(
                  width: size,
                  height: size,
                  child: Container(
                      padding: EdgeInsets.all(size! / 4), child: image),
                ),
              )),
          const Spacer(),
          SizedBox(
            height: textStyle!.fontSize! * textStyle!.height! * 2,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
          )
        ],
      ),
    );
  }
}
