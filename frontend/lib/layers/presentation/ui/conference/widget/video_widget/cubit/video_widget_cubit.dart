import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/video_widget/cubit/video_widget_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/util/util.dart';

class VideoWidgetCubit extends Cubit<VideoWidgetState> {
  VideoWidgetCubit(StreamRenderer videoRenderer)
      : super(VideoWidgetState.initial(videoRenderer)) {
    load();
  }

  void load() {
    // optional init
  }

  void updateAudioMute(bool isMuted) {
    emit(state.copyWith(audioMuted: isMuted));
  }

  void updateVideoMute(bool isMuted) {
    emit(state.copyWith(videoMuted: isMuted));
  }

  void updateVideoFlowing(bool flowing) {
    emit(state.copyWith(isVideoFlowing: flowing));
  }

  void updateSpeaking(bool isSpeaking) {
    emit(state.copyWith(isSpeaking: isSpeaking));
  }

  void updateSize(double width, double height) {
    emit(state.copyWith(itemWidth: width, itemHeight: height));
  }

  void updateStream(String id, StreamRenderer stream) {
    emit(state.copyWith(
      videoRenderer: stream,
      audioMuted: stream.isAudioMuted,
      videoMuted: stream.isVideoMuted,
      isVideoFlowing: stream.isVideoFlowing,
      isSpeaking: stream.isTalking,
      handUp: stream.isHandUp,
      moduleScores: stream.moduleScores,
    ));
  }
}
