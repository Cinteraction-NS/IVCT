
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';


Widget rtcVideoWidget(BuildContext context, RTCVideoRenderer renderer, bool screenshare, double width, double height, String id, String publisherName, Widget userAvatar)
{
  var isPortrait = renderer.videoHeight > renderer.videoWidth;

  return ClipRRect(
    borderRadius: BorderRadius.circular(17), // match this to parent’s radius
    child: RTCVideoView(
      renderer,
      placeholderBuilder: (context) {
        return  userAvatar;
      },
      filterQuality: FilterQuality.none,
      objectFit: (screenshare || isPortrait)
          ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
          : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      mirror: !screenshare,
    ),
  );

}
