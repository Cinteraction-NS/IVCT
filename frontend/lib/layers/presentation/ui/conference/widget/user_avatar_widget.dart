import 'package:flutter/material.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../../../../core/util/util.dart';
import '../../profile/ui/widget/user_image.dart';

Widget getUserAvatar(int userId, double halfHeight, StreamRenderer remoteStream)
{
  return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.6,
          colors: [
            ColorConstants.getRandomColor(userId),
            ColorConstants.getRandomColor(userId, shade: 700),
          ],
        ),
        border: Border.all(
          color: remoteStream.isTalking == true
              ? Colors.white
              : Colors.transparent,
          width: remoteStream.isTalking == true ? 2.0 : 0.0,
        ),
      ),
      child: Center(
          child: UserImage.size(
              [remoteStream.getUserImageDTO()],
              halfHeight,
              700)));
}