part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.scheduleStartDateTime,
    required this.loading,
    this.nextMeeting,
  });

  final DateTime? scheduleStartDateTime;
  final bool loading;
  final Meeting? nextMeeting;

  const HomeState.initial({
    DateTime? scheduleDate,
  }) : this(
          scheduleStartDateTime: scheduleDate,
          loading: false,
        );

  HomeState copyWith({
    DateTime? scheduleDate,
    bool? loading,
    Meeting? nextMeeting,
  }) {
    return HomeState(
      scheduleStartDateTime: scheduleDate ?? scheduleStartDateTime,
      loading: loading ?? this.loading,
      nextMeeting: nextMeeting ?? this.nextMeeting,
    );
  }

  @override
  List<Object?> get props => [
        scheduleStartDateTime,
        loading,
        nextMeeting,
      ];
}
