// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void mergeVideos(List<dynamic> blobs) {
  final js.JsArray blobArray = js.JsArray.from(blobs);
  js.context.callMethod('concatenateVideos', [blobArray]);
}
