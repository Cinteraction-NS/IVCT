// media_stream_js.dart
// Only works on Flutter Web

// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
import 'package:flutter_webrtc/flutter_webrtc.dart';

extension MediaStreamJS on MediaStream {
  dynamic get jsObject => js_util.getProperty(this, 'jsObject');
}
