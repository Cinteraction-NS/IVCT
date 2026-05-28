import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/layers/domain/entities/api_error.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/util/util.dart';
import '../../../domain/entities/chat_message.dart';

enum RecordingStatus {
  loading,
  recording,
  notRecording,
}

class ConferenceState extends Equatable {
  final bool isInitial;
  final bool isEnded;
  final bool isCallStarted;
  final Map<dynamic, StreamRenderer>? streamRenderers;
  final Map<dynamic, StreamRenderer>? streamScreenShares;
  final Map<dynamic, StreamRenderer>? streamSubscribers;
  final List<ChatMessage>? messages;
  final bool audioMuted;
  final bool handUp;
  final bool videoMuted;
  final bool screenShared;
  final bool engagementEnabled;
  final bool showingChat;
  final bool showingMicIsOff;
  final bool showingParticipants;
  final int? numberOfStreams;
  final int? avgEngagement;
  final int? unreadMessages;
  final int? meetId;
  final int? chatId;
  final int numberOfStreamsCopy;
  final int screenShareId;
  final bool isGridLayout;
  final String? error;
  final String? toastMessage;
  final RecordingStatus recording;

  const ConferenceState(
      {required this.isInitial,
      required this.isEnded,
      required this.isCallStarted,
      this.streamRenderers,
      this.streamScreenShares,
      this.streamSubscribers,
      this.messages,
      required this.audioMuted,
      required this.handUp,
      required this.videoMuted,
      required this.screenShared,
      required this.engagementEnabled,
      required this.showingChat,
      required this.showingMicIsOff,
      required this.showingParticipants,
      this.numberOfStreams,
      this.avgEngagement,
      this.unreadMessages,
      this.meetId,
      this.chatId,
      required this.screenShareId,
      required this.numberOfStreamsCopy,
      required this.isGridLayout,
      this.error,
      this.toastMessage,
      required this.recording});

  const ConferenceState.initial(
      {bool isInitial = true,
      bool isEnded = false,
      bool isCallStarted = false,
      Map<dynamic, StreamRenderer>? streamRenderers,
      Map<dynamic, StreamRenderer>? streamScreenShares,
      bool audioMuted = false,
      bool videoMuted = false,
      bool handUp = false,
      bool screenShared = false,
      bool engagementEnabled = true,
      bool showingChat = false,
      bool showingParticipants = false,
      int? numberOfStreamsCopy,
      int? isGridLayout,
      int? avgEngagement = 0,
      int? unreadMessages = 0,
      int screenShareId = -1,
      RecordingStatus recording = RecordingStatus.notRecording})
      : this(
            isInitial: isInitial,
            isEnded: isEnded,
            isCallStarted: isCallStarted,
            audioMuted: audioMuted,
            handUp: handUp,
            videoMuted: videoMuted,
            numberOfStreamsCopy: 1,
            isGridLayout: true,
            engagementEnabled: engagementEnabled,
            avgEngagement: avgEngagement,
            screenShared: screenShared,
            showingChat: showingChat,
            showingMicIsOff: false,
            showingParticipants: showingParticipants,
            recording: recording,
            screenShareId: screenShareId);

  const ConferenceState.ended(
      {bool isInitial = false,
      bool isEnded = true,
      bool isCallStarted = false,
      Map<dynamic, StreamRenderer>? streamRenderers,
      Map<dynamic, StreamRenderer>? streamScreenShares,
      bool audioMuted = false,
      bool videoMuted = false,
      bool handUp = false,
      bool screenShared = false,
      bool engagementEnabled = true,
      bool showingChat = false,
      bool showingParticipants = false,
      RecordingStatus recording = RecordingStatus.notRecording})
      : this(
            isInitial: isInitial,
            isEnded: isEnded,
            isCallStarted: isCallStarted,
            audioMuted: audioMuted,
            videoMuted: videoMuted,
            handUp: handUp,
            numberOfStreamsCopy: 1,
            isGridLayout: true,
            engagementEnabled: engagementEnabled,
            screenShared: screenShared,
            showingChat: showingChat,
            showingMicIsOff: false,
            showingParticipants: showingParticipants,
            recording: recording,
            screenShareId: -1);

  const ConferenceState.error(
      {bool isInitial = false,
      bool isEnded = true,
      bool isCallStarted = false,
      Map<dynamic, StreamRenderer>? streamRenderers,
      Map<dynamic, StreamRenderer>? streamScreenShares,
      bool audioMuted = false,
      bool videoMuted = false,
      bool handUp = false,
      bool screenShared = false,
      bool engagementEnabled = true,
      bool showingChat = false,
      bool showingParticipants = false,
      required String error,
      RecordingStatus recording = RecordingStatus.notRecording})
      : this(
            isInitial: isInitial,
            isEnded: isEnded,
            isCallStarted: isCallStarted,
            audioMuted: audioMuted,
            videoMuted: videoMuted,
            handUp: handUp,
            numberOfStreamsCopy: 1,
            isGridLayout: true,
            showingMicIsOff: false,
            engagementEnabled: engagementEnabled,
            screenShared: screenShared,
            error: error,
            showingChat: showingChat,
            showingParticipants: showingParticipants,
            recording: recording,
            screenShareId: -1);

  ConferenceState copyWith({
    bool? isInitial,
    bool? isEnded,
    bool? isCallStarted,
    Map<dynamic, StreamRenderer>? streamRenderers,
    Map<dynamic, StreamRenderer>? streamScreenShares,
    Map<dynamic, StreamRenderer>? streamSubscribers,
    List<ChatMessage>? messages,
    int? numberOfStreams,
    int? numberOfStreamsCopy,
    int? avgEngagement,
    int? unreadMessages,
    bool? audioMuted,
    bool? videoMuted,
    bool? handUp,
    bool? screenShared,
    bool? engagementEnabled,
    bool? showingChat,
    bool? showingMicIsOff,
    bool? showingParticipants,
    bool? isGridLayout,
    RecordingStatus? recording,
    int? meetId,
    int? chatId,
    String? toastMessage,
    int? screenShareId,
  }) {
    return ConferenceState(
        isInitial: isInitial ?? this.isInitial,
        isEnded: isEnded ?? this.isEnded,
        isCallStarted: isCallStarted ?? this.isCallStarted,
        streamRenderers: streamRenderers ?? this.streamRenderers,
        streamScreenShares: streamScreenShares ?? this.streamScreenShares,
        streamSubscribers: streamSubscribers ?? this.streamSubscribers,
        numberOfStreams: numberOfStreams ?? this.numberOfStreams,
        audioMuted: audioMuted ?? this.audioMuted,
        videoMuted: videoMuted ?? this.videoMuted,
        handUp: handUp ?? this.handUp,
        screenShared: screenShared ?? this.screenShared,
        engagementEnabled: engagementEnabled ?? this.engagementEnabled,
        numberOfStreamsCopy: numberOfStreamsCopy ?? this.numberOfStreamsCopy,
        avgEngagement: avgEngagement ?? this.avgEngagement,
        isGridLayout: isGridLayout ?? this.isGridLayout,
        showingChat: showingChat ?? this.showingChat,
        showingParticipants: showingParticipants ?? this.showingParticipants,
        messages: messages ?? this.messages,
        unreadMessages: unreadMessages ?? this.unreadMessages,
        meetId: meetId ?? this.meetId,
        chatId: chatId ?? this.chatId,
        recording: recording ?? this.recording,
        showingMicIsOff: showingMicIsOff ?? this.showingMicIsOff,
        screenShareId: screenShareId ?? this.screenShareId,
        toastMessage: toastMessage);
  }

  @override
  List<Object?> get props => [
        isInitial,
        isEnded,
        isCallStarted,
        streamRenderers,
        streamScreenShares,
        streamSubscribers,
        numberOfStreams,
        audioMuted,
        videoMuted,
        numberOfStreamsCopy,
        isGridLayout,
        engagementEnabled,
        avgEngagement,
        screenShared,
        showingChat,
        showingParticipants,
        messages,
        unreadMessages,
        meetId,
        chatId,
        recording,
        toastMessage,
        handUp,
        showingMicIsOff,
        screenShareId
      ];
}
