part of 'meetings_cubit.dart';

class MeetingState extends Equatable {

  const MeetingState(
      {required this.meetings, required this.isLoading, required this.isShowingPastMeetings});

  @override
  List<Object?> get props => [meetings, isLoading, isShowingPastMeetings];
  final List<Meeting> meetings;
  final bool isShowingPastMeetings;
  final bool isLoading;


  const MeetingState.initial
      ({
    List<Meeting> meetings = const [],
    bool isShowingPastMeetings = true,
    bool isLoading = false,
  }) : this(
      meetings: meetings,
      isLoading: isLoading,
      isShowingPastMeetings: isShowingPastMeetings
  );

  MeetingState copyWith(
      {List<Meeting>? meetings, bool? isLoading, bool? isShowingPastMeetings}) {
    return MeetingState(
        meetings: meetings ?? this.meetings,
        isLoading: isLoading ?? false,
        isShowingPastMeetings: isShowingPastMeetings ??
            this.isShowingPastMeetings);
  }
}

