import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/video_widget/cubit/video_widget_cubit.dart';

import '../../../../../../core/util/util.dart';

class ParticipantManager {
  final Map<String, VideoWidgetCubit> _cubits = {};

  VideoWidgetCubit getOrCreate(String id, StreamRenderer stream) {
    return _cubits.putIfAbsent(id, () {
      return VideoWidgetCubit(stream);
    });
  }

  void updateStream(String id, StreamRenderer updatedStream) {
    _cubits[id]?.updateStream(id, updatedStream);
  }

  void disposeAll() {
    for (final cubit in _cubits.values) {
      cubit.close();
    }
    _cubits.clear();
  }
}
