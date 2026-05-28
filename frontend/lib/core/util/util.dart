import 'dart:async';
import 'dart:typed_data';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/util/platform/platform_stub.dart';
import 'package:cinteraction_vc/layers/data/dto/ai/ai_module_dto.dart';
import 'package:cinteraction_vc/layers/presentation/ui/charts/ui/widget/chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../layers/data/dto/chat/chat_detail_dto.dart';
import '../../layers/data/dto/engagement_dto.dart';
import '../../layers/presentation/ui/profile/ui/widget/user_image.dart';
import '../janus/janus_client.dart';

class StreamRenderer {
  RTCVideoRenderer videoRenderer = RTCVideoRenderer();
  MediaStream? mediaStream;
  String id;
  String? publisherId;
  String publisherName;

  Map<ModuleDto, int> moduleScores = {};
  String? audioMid;
  String? videoMid;
  bool? initialSet;
  bool? isAudioMuted;
  bool? isHandUp;
  String? imageUrl;
  // List<bool> selectedQuality = [false, false, true];
  bool? isVideoMuted;
  bool? isSharing;

  bool? mirrorVideo = false;
  ConfigureStreamQuality subStreamQuality = ConfigureStreamQuality.HIGH;
  // bool? isTalking;
  Uint8List? lastFrameBytes;

  bool savingFrames = false;
  Timer? fallbackTimer;

  // bool? isVideoFlowing;
  bool bitrateIsOk = true;
  bool? _isVideoFlowing;

  bool? get isVideoFlowing => _isVideoFlowing!;

  List<LineSeries> modulesGraphData = List.empty(growable: true);

  void addSpot(String moduleName, int value, int moduleId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();

    // Find existing line by name
    final existing = modulesGraphData.firstWhere(
          (s) => s.id == moduleName,
      orElse: () => createLine(moduleName, moduleId),
    );

    // If new, add it to the list
    if (!modulesGraphData.contains(existing)) {
      modulesGraphData.add(existing);
    }

    // Add a new spot
    existing.spots.add(FlSpot(timestamp, value.toDouble()));

    // Keep only the latest 10 spots
    if (existing.spots.length > 10) {
      // remove oldest ones (FIFO)
      existing.spots.removeRange(0, existing.spots.length - 10);
    }
  }

  LineSeries createLine(String name, int moduleId)
{
  return LineSeries(
    id: name,
    spots: [],
    color: ColorConstants.graphColorFor(moduleId),
    isCurved: false,
    showDots: false,
    strokeWidth: 2,
    fillBelowLine: true,
  );
}




  set setVideoFlowing(bool? value) {
    // fallbackTimer?.cancel();
    // showLastFrame = false;
    // if (!value! && !isVideoMuted!) {
    //   showLastFrame = true;
    //   fallbackTimer = Timer(const Duration(seconds: 5), () {
    //     showLastFrame = false;
    //   });
    // }
    _isVideoFlowing = value;
  }

  UserImageDto getUserImageDTO() {
    return UserImageDto(
        id: int.parse(publisherId ?? "0"),
        name: publisherName,
        imageUrl: imageUrl ?? "");
  }

  Future<void> dispose({bool disposeTrack = true}) async {
    if (!isRendererDisposed(videoRenderer)) {
      if (disposeTrack) await stopAllTracks(mediaStream);
      await mediaStream?.dispose();
      videoRenderer.srcObject = null;
      await videoRenderer.dispose();
      savingFrames = false;
    }
  }

  bool? _isTalking;
  bool? get isTalking => _isTalking;
  DateTime? talkingStartTime = DateTime.now();

  set isTalking(bool? value) {
    if (value == true && _isTalking != true) {
      talkingStartTime = DateTime.now();
    }
    _isTalking = value;
  }

  bool isRendererDisposed(RTCVideoRenderer renderer) {
    return renderer.textureId == null;
  }

  StreamRenderer(this.id, this.publisherName);

  Future<void> init({bool saveFrames = false}) async {
    print("init streamRenderer $id");

    mediaStream = await createLocalMediaStream('mediaStream_$id');
    isAudioMuted = false;
    isVideoMuted = false;
    isSharing = false;
    initialSet = false;
    setVideoFlowing = true;
    isTalking = false;
    isHandUp = false;
    videoRenderer = RTCVideoRenderer();
    await videoRenderer.initialize();
    videoRenderer.srcObject = mediaStream;
    // saveLastFrame();
    savingFrames = saveFrames;
    if (savingFrames) saveLastFrame();
  }

  void saveLastFrame() async {
    // print("save the last FRAME ${publisherName}");
    // print(" ${savingFrames} ${isVideoFlowing!}");
    if (savingFrames) {
      if (isVideoFlowing!) {
        try {
          var buffer = await captureFrameFromVideo(this);
          lastFrameBytes = Uint8List.view(buffer!);
          // print("${publisherName}, lastFrameBytes: ${lastFrameBytes?.lengthInBytes}");
        } catch (e) {
          print("Failed to capture frame: $e");
        }
      }

      // if(videoRenderer.srcObject != null){
      await Future.delayed(const Duration(seconds: 1));
      saveLastFrame();
      // }
    }
  }
}

class Publisher {
  int id;
  String displayName;
  List<PStream> streams;

  Publisher({
    required this.id,
    required this.displayName,
    required this.streams,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      id: json['id'],
      displayName: json['display'],
      streams: (json['streams'] as List)
          .map((stream) => PStream.fromJson(stream as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'streams': streams.map((stream) => stream.toJson()).toList(),
      };
}

class PStream {
  String type;
  int minindex;
  String mid;
  String? codec;
  bool? fec;
  bool? talking;
  bool? moderated;
  bool? simulcast;

  PStream({
    required this.type,
    required this.minindex,
    required this.mid,
  });

  factory PStream.fromJson(Map<String, dynamic> json) {
    return PStream(
      type: json['type'],
      minindex: json['mindex'],
      mid: json['mid'],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'minindex': minindex,
        'mid': mid,
      };
}

class VideoRoomPluginStateManager {
  Map<String, StreamRenderer> streamsToBeRendered =
      {}; //streams sends to ui to be rendered
  Map<int, Publisher> feedIdToDisplayStreamsMap =
      {}; //store id, displayName, streams from publishers
  Map<dynamic, dynamic> feedIdToMidSubscriptionMap =
      {}; //feed id as a key, mid as a value
  Map<dynamic, dynamic> subStreamsToFeedIdMap = {}; //
  Map<int, int> lastSpeakingTimeMap = {};

  reset() {
    streamsToBeRendered.clear();
    feedIdToDisplayStreamsMap.clear();
    subStreamsToFeedIdMap.clear();
    feedIdToMidSubscriptionMap.clear();
  }
}
