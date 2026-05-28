import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';

import '../../../assets/colors/Colors.dart';

class EngagementProgress extends StatelessWidget {
  final int engagement;
  final double? width;
  final double? height;

  const EngagementProgress(
      {super.key,
      required this.engagement,
      this.width = 133,
      this.height = 18});

  @override
  Widget build(BuildContext context) {

    var eng = engagement >= 0 ? engagement : 0;
    var isVisible = eng > 25;



    return Stack(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          width: width,
          height: height,
          alignment: Alignment.centerLeft,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: ColorConstants.kGray5,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraint) {
               return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(
                    begin: 0,
                    end: eng.toDouble(),
                  ),
                  builder: (context, value, _) {
                    final colorTween = ColorTween(
                      begin: getProgressColor(0),
                      end: getProgressColor(100),
                    );

                    return Container(
                      width: constraint.maxWidth * value / 100,
                      height: double.maxFinite,
                      color: colorTween.transform(value / 100)!,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(left: 3, right: 3),
                      child: Visibility(
                        visible: isVisible,
                        child: getEngagementText(context, value.toInt()),
                      ),
                    );
                    },
                );
          }),
        ),
        Visibility(
          visible: !isVisible,
          child: Positioned.fill(
              right: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  ((eng / 100)).toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelMedium,
                ),
              )),
        )
      ],
    );
  }
}

Color getProgressColor(int engagement) {
  if (engagement > 65) {
    return ColorConstants.kStateSuccess;
  }

  if (engagement > 40) {
    return ColorConstants.kEngProgress65;
  } else {
    return ColorConstants.kEngProgress30;
  }
}

Text getEngagementText(BuildContext context, int engagement) {
  return Text(
    "$engagement%",
    maxLines: 1,
    textAlign: TextAlign.center,
    style: context.textTheme.labelMedium?.copyWith(color: Colors.white),
  );
}
