import 'package:json_annotation/json_annotation.dart';

class SessionMeeting {
  SessionMeeting(
      {required this.meetingId,
      required this.duration,
      required this.averageEngagement,
      required this.users,
      required this.date});

  @JsonKey(name: 'meeting_id')
  int meetingId;

  int duration;

  @JsonKey(name: 'avg_engagement')
  double averageEngagement;

  int users;

  DateTime? date;
}
