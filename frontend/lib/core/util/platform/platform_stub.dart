import 'dart:math';
import 'dart:typed_data';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/rtc_video_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../assets/colors/Colors.dart';
import '../../../layers/presentation/ui/profile/ui/widget/user_image.dart';
import '../util.dart';

void redirectToDesktopApp() {
  // Do nothing or show alternative message
  print("Not on web, no redirection needed.");
}

void startMeetOnDesktop(int roomId)
{

}

Widget getVideoView(BuildContext context, RTCVideoRenderer renderer, bool mirror, double width, double height, String id, String publisherName, Widget userImage)
{
  return rtcVideoWidget(context, renderer, mirror, width, height, id, publisherName, userImage);
}


Future<ByteBuffer?> captureFrameFromVideo(StreamRenderer renderer) async {
  var image = await renderer.mediaStream
      ?.getVideoTracks()
      .first
      .captureFrame();

  return image;
}
