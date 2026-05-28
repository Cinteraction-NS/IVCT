import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/rtc_video_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui_web' as ui; // Only works on web

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../assets/colors/Colors.dart';
import '../util.dart';
void redirectToDesktopApp() {
  var os = detectWebOS();

  print("user is on $os");

  // html.window.alert("Please use the $os desktop app.");
  // if (os == 'Windows')
  // {
  // html.window.location.href = 'https://drive.usercontent.google.com/download?id=13VeRRJY5gZ6dJSoExPfl0TBwhYQDYqIw&export=download&authuser=0';
  //
  // } if (os=='macOS') {
  //   html.window.location.href =
  //   'https://drive.google.com/file/d/1nx5_hwZKgCh1lruZigOdyqJEW9_FmB6m/view?usp=sharing';
  // }

  // const timeout = Duration(seconds: 2);
  // const fallbackUrl = 'https://drive.google.com/file/d/1nx5_hwZKgCh1lruZigOdyqJEW9_FmB6m/view?usp=sharing';
  //
  // final iframe = html.IFrameElement()
  //   ..style.display = 'none'
  //   ..src = 'cinteraction://open?route=/home/meeting/1223';
  //
  // html.document.body!.append(iframe);
  //
  // Future.delayed(timeout, () {
  //   iframe.remove();
  //   html.window.location.href = fallbackUrl;
  // });

}

void startMeetOnDesktop(int roomId) {
  var os = detectWebOS();
   html.window.alert("Please use the $os desktop app.");
  // if (os == 'Windows')
  // {
  // html.window.location.href = 'https://drive.usercontent.google.com/download?id=13VeRRJY5gZ6dJSoExPfl0TBwhYQDYqIw&export=download&authuser=0';
  //
  // } if (os=='macOS') {
  //   html.window.location.href =
  //   'https://drive.google.com/file/d/1nx5_hwZKgCh1lruZigOdyqJEW9_FmB6m/view?usp=sharing';
  // }

  const timeout = Duration(seconds: 2);
  const fallbackUrl = 'https://drive.google.com/file/d/1nx5_hwZKgCh1lruZigOdyqJEW9_FmB6m/view?usp=sharing';

  final iframe = html.IFrameElement()
    ..style.display = 'none'
    ..src = 'cinteraction://open?route=/home/meeting/1223';

  html.document.body!.append(iframe);

  Future.delayed(timeout, () {
    iframe.remove();
    html.window.location.href = fallbackUrl;
  });
}

String detectWebOS() {
  final ua = html.window.navigator.userAgent.toLowerCase();

  if (ua.contains('windows')) return 'Windows';
  if (ua.contains('mac os')) return 'macOS';
  if (ua.contains('linux')) return 'Linux';
  if (ua.contains('android')) return 'Android';
  if (ua.contains('iphone') || ua.contains('ipad')) return 'iOS';
  return 'Unknown';
}

Widget getVideoView(BuildContext context, RTCVideoRenderer renderer, bool mirror, double width, double height, String id, String publisherName, Widget userImage) {
  // ui.platformViewRegistry.registerViewFactory(id, (int _) {
  //   final html.MediaStream nativeStream = getNativeMediaStream(renderer.srcObject!);
  //
  //   final video = html.VideoElement()
  //     ..id = id
  //     ..autoplay = true
  //     ..muted = true
  //     ..srcObject = nativeStream
  //     ..style.objectFit = _boxFitToCss(
  //               mirror
  //                   ? BoxFit.contain
  //                   : BoxFit.cover)
  //     ..style.transform = mirror ? 'scaleX(-1)' : 'none'
  //     ..style.width = '100%'
  //     ..style.height = '100%';
  //
  //   return video;
  // });
  //
  // return HtmlElementView(viewType: id);
// print("video width: ${renderer.videoWidth} for ${renderer.textureId}");
// print("video height: ${renderer.videoHeight} for ${renderer.textureId}");
// print(renderer.videoWidth);
  return rtcVideoWidget(context, renderer, mirror, width, height, id, publisherName, userImage);
}

String _boxFitToCss(BoxFit fit) {
  switch (fit) {
    case BoxFit.contain:
      return 'contain';
    case BoxFit.cover:
      return 'cover';
    case BoxFit.fill:
      return 'fill';
    case BoxFit.none:
      return 'none';
    default:
      return 'cover';
  }
}

html.MediaStream getNativeMediaStream(MediaStream stream) {
  // This cast is valid only on Web, where MediaStreamWeb wraps html.MediaStream
  final dynamic anyStream = stream;
  final nativeStream = anyStream.jsStream; // This is safe on Web only
  if (nativeStream is html.MediaStream) {
    return nativeStream;
  }
  throw Exception("Could not extract native MediaStream");
}

Future<ByteBuffer?> captureFrameFromVideo(StreamRenderer renderer, {int width = 640, int height = 360}) async {
  // final video = html.document.getElementById(renderer.id) as html.VideoElement?;
  //
  // if (video == null || video.videoWidth == 0 || video.videoHeight == 0) {
  //   throw Exception("Video element not found or not ready (ID: ${renderer.id})");
  // }
  //
  // final canvas = html.CanvasElement(width: width, height: height);
  // final ctx = canvas.context2D;
  //
  // // Draw video onto scaled canvas (auto-resizes to 640x360)
  // ctx.drawImageScaled(video, 0, 0, width, height);
  //
  // // Convert to compressed JPEG (quality = 0.7)
  // final blob = await canvas.toBlob('image/jpeg', 0.7);
  // final reader = html.FileReader();
  // reader.readAsDataUrl(blob!);
  // await reader.onLoad.first;
  //
  // final base64 = (reader.result as String).split(',').last;
  // final bytes = base64Decode(base64);
  // return bytes.buffer;

  var image = await renderer.mediaStream
      ?.getVideoTracks()
      .first
      .captureFrame();

  return image;
}