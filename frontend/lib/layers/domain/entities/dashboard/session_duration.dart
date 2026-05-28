import 'package:cinteraction_vc/layers/domain/entities/dashboard/session_meeting.dart';
import 'package:json_annotation/json_annotation.dart';



class SessionDuration {
  SessionDuration(
      {required this.averageDuration,
      required this.averageUsers,
      required this.meetings});

  @JsonKey(name: 'avg_duration')
  double averageDuration;
  @JsonKey(name: 'avg_users')
  double averageUsers;

  List<SessionMeeting> meetings;
}
