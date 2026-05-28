import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/io/network/models/participant.dart';
import '../../../core/janus/janus_client.dart';
import '../../../core/util/util.dart';
import '../../data/dto/meetings/meeting_dto.dart';
import '../entities/api_response.dart';
import '../entities/chat_message.dart';

abstract class ConferenceRepo {
  const ConferenceRepo();

  Future<void> initialize({required int roomId, required String displayName});

  Stream<Map<dynamic, StreamRenderer>> getStreamRendererStream();
  Stream<Map<dynamic, StreamRenderer>> getConferenceScreenShareStream();

  Stream<String> getConferenceEndedStream();
  Stream<void> getUserTalkingStream();
  Stream<List<ChatMessage>> getConferenceMessagesStream();

  Stream<Map<dynamic, StreamRenderer>>  getSubscribersStream();

  Stream<int> getAvgEngagementStream();

  Future<void> finishCall();

  Future<void> mute({required String kind, required bool muted});

  Future<void> changeSubstream(
      {required String remoteStreamId, required int substream});
  Future<void> kick({required String id});
  Future<void> handUp({required bool handUp});

  Future<void> unPublish();

  Future<void> publish();

  Future<void> ping({required String msg});

  Future<void> toggleEngagement({required bool enabled});

  Future<List<Participant>> getParticipants();

  Future<void> switchCamera();

  Future<void> unPublishById({required String id});

  Future<void> publishById({required String id});
  Future<void> muteById({required String id});

  Future<void> changeSubStream(
      {required ConfigureStreamQuality quality,
      required StreamRenderer remoteStream});
  Future<void> shareScreen();

  Future<MeetingDto?> startCall();

  Future<ApiResponse<bool>> sendMessage(String msg,
      {List<PlatformFile>? uploadedFiles});

  Future<bool> startRecording();
  Future<void> stopRecording();
  Stream<String> getToastStream();
  Stream<void> getDisposeScreenSharingStream();
}
