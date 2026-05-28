import 'package:cinteraction_vc/layers/data/dto/ai/ai_module_dto.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../../core/util/util.dart';

class VideoWidgetState extends Equatable {
  final double itemWidth;
  final double itemHeight;
  final bool videoMuted;
  final bool isVideoFlowing;
  final bool audioMuted;
  final bool handUp;
  final bool isSpeaking;
  final Map<ModuleDto, int>? moduleScores;
  final int publisherId;
  final String publisherName;
  final StreamRenderer videoRenderer;

  const VideoWidgetState({
    required this.itemWidth,
    required this.itemHeight,
    required this.videoMuted,
    required this.isVideoFlowing,
    required this.audioMuted,
    required this.isSpeaking,
    required this.handUp,
    required this.moduleScores,
    required this.publisherId,
    required this.publisherName,
    required this.videoRenderer,
  });

  const VideoWidgetState.initial(
    StreamRenderer videoRenderer, {
    bool videoMuted = false,
    bool isVideoFlowing = true,
    bool audioMuted = false,
    bool isSpeaking = false,
    bool handUp = false,
        Map<ModuleDto, int> moduleScores = const {},
    int publisherId = 0,
    String publisherName = "1",
  }) : this(
          itemWidth: 0.0,
          itemHeight: 0.0,
          videoMuted: videoMuted,
          isVideoFlowing: isVideoFlowing,
          audioMuted: audioMuted,
          isSpeaking: isSpeaking,
          handUp: handUp,
          moduleScores: moduleScores,
          publisherId: publisherId,
          publisherName: publisherName,
          videoRenderer: videoRenderer,
        );

  VideoWidgetState copyWith({
    double? itemWidth,
    double? itemHeight,
    bool? videoMuted,
    bool? isVideoFlowing,
    bool? audioMuted,
    bool? isSpeaking,
    bool? handUp,
    Map<ModuleDto, int>? moduleScores,
    int? publisherId,
    String? publisherName,
    StreamRenderer? videoRenderer,
  }) {
    return VideoWidgetState(
      itemWidth: itemWidth ?? this.itemWidth,
      itemHeight: itemHeight ?? this.itemHeight,
      videoMuted: videoMuted ?? this.videoMuted,
      isVideoFlowing: isVideoFlowing ?? this.isVideoFlowing,
      audioMuted: audioMuted ?? this.audioMuted,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      handUp: handUp ?? this.handUp,
      moduleScores: moduleScores ?? this.moduleScores,
      publisherId: publisherId ?? this.publisherId,
      publisherName: publisherName ?? this.publisherName,
      videoRenderer: videoRenderer ?? this.videoRenderer,
    );
  }

  @override
  List<Object?> get props => [
        itemWidth,
        itemHeight,
        videoMuted,
        isVideoFlowing,
        audioMuted,
        isSpeaking,
        handUp,
        moduleScores,
        publisherId,
        publisherName,
        videoRenderer,
      ];
}
