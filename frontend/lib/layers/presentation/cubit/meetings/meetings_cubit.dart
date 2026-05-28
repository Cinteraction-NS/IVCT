import 'package:cinteraction_vc/core/logger/loggy_types.dart';
import 'package:cinteraction_vc/layers/domain/usecases/meeting/meeting_use_cases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/meetings/meeting.dart';

part 'meetings_state.dart';

class MeetingCubit extends Cubit<MeetingState> with BlocLoggy {
  MeetingCubit({
    required this.meetingUseCases,
  }) : super(const MeetingState.initial()) {
    _load();
  }

  final MeetingUseCases meetingUseCases;

  void _load() {
    loadMeetings();
  }

  var meetingLoadPage = 1;
  var meetingLastPage = 100;

  void loadMeetings() async {
    if (state.isLoading) {
      return;
    }

    if (meetingLoadPage > meetingLastPage) {
      return;
    }

    emit(state.copyWith(isLoading: true));
    var meetings =
        await meetingUseCases.getPastMeetingsUseCase(meetingLoadPage);
    if (meetings.error == null) {
      var meetingsList = state.meetings;
      if (meetingsList.isEmpty) {
        meetingsList = meetings.response?.meetings ?? List.empty();
        meetingLoadPage++;
      } else {
        meetingsList.addAll(meetings.response?.meetings ?? List.empty());
        if ((meetings.response?.meetings ?? List.empty()).isNotEmpty) {
          meetingLoadPage++;
        }
      }

      meetingLastPage = meetings.response?.lastPage ?? 100;
      emit(state.copyWith(meetings: meetingsList));
    } else {
      emit(state.copyWith(meetings: List.empty()));
    }
  }

  void loadScheduledMeetings() async {
    emit(state.copyWith(isLoading: true));
    var meetings = await meetingUseCases.getScheduleMeetings();

    if (meetings.error == null) {
      emit(state.copyWith(meetings: meetings.response ?? List.empty()));
    } else {
      emit(state.copyWith(meetings: List.empty()));
    }
  }

  void tabChanged() {
    meetingLoadPage = 1;
    meetingLastPage = 100;
    emit(state.copyWith(isShowingPastMeetings: !state.isShowingPastMeetings));
  }
}
