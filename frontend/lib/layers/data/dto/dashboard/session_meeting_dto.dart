import '../../../domain/entities/dashboard/session_meeting.dart';

class SessionMeetingDto extends SessionMeeting {
  SessionMeetingDto(
      {required super.meetingId,
      required super.duration,
      required super.averageEngagement,
      required super.users,
      required super.date});

  factory SessionMeetingDto.fromJson(Map<String, dynamic> json) {
    return SessionMeetingDto(
      averageEngagement: (json['avg_engagement'] is int)
          ? (json['avg_engagement'] as int).toDouble()
          : json['avg_engagement'] as double,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      users: json['users'] as int,
      duration: json['duration'] as int,
      meetingId: json['meeting_id'] as int,
    );
  }
}
