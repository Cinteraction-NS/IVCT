part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  DashboardState(
      {this.loading,
      this.meetingAttendedSum,
      this.realizedMeetings,
      this.missedMeetings,
      required this.meetingAttended,
      this.avgDurationPerSession,
      this.avgUsersPerMeeting,
      required this.usersPerMeeting,
      required this.durationsPerSession,
      this.engagementData,
      this.engagementLoading});

  @override
  List<Object?> get props => [
        loading,
        meetingAttendedSum,
        durationsPerSession,
        usersPerMeeting,
        engagementData,
        engagementLoading
      ];

  final bool? loading;
  final bool? engagementLoading;
  final int? meetingAttendedSum;
  final int? realizedMeetings;
  final int? missedMeetings;
  final List<double> meetingAttended;

  final int? avgUsersPerMeeting;
  final List<double> usersPerMeeting;

  final int? avgDurationPerSession;
  final List<double> durationsPerSession;

  final EngagementTotalAverageDto? engagementData;

  DashboardState.initial(
      {bool loading = false,
      required List<double> meetingAttended,
      required List<double> usersPerMeeting,
      required List<double> durationsPerSession})
      : this(
            loading: loading,
            meetingAttended: meetingAttended,
            usersPerMeeting: usersPerMeeting,
            durationsPerSession: durationsPerSession);

  DashboardState copyWith(
      {bool? loading,
      int? meetingAttendedSum,
      int? realizedMeetings,
      int? missedMeetings,
      int? avgUsersPerMeeting,
      int? avgDurationPerSession,
      List<double>? meetingAttended,
      List<double>? usersPerMeeting,
      List<double>? durationsPerSession,
      EngagementTotalAverageDto? engagementData,
      bool? engagementLoading}) {
    return DashboardState(
      loading: loading,
      meetingAttendedSum: meetingAttendedSum ?? this.meetingAttendedSum,
      realizedMeetings: realizedMeetings ?? this.realizedMeetings,
      missedMeetings: missedMeetings ?? this.missedMeetings,
      avgUsersPerMeeting: avgUsersPerMeeting ?? this.avgUsersPerMeeting,
      usersPerMeeting: usersPerMeeting ?? this.usersPerMeeting,
      meetingAttended: meetingAttended ?? this.meetingAttended,
      durationsPerSession: durationsPerSession ?? this.durationsPerSession,
      engagementData: engagementData ?? this.engagementData,
      engagementLoading: engagementLoading ?? this.engagementLoading,
    );
  }
}
