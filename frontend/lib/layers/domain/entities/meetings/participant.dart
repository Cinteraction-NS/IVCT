import 'package:json_annotation/json_annotation.dart';

class MeetingParticipant {
  MeetingParticipant({
    required this.id,
    required this.meetingId,
    required this.email,
    this.userId,
  });

  int id;

  @JsonKey(name: 'meeting_id')
  int meetingId;

  String email;

  @JsonKey(name: 'user_id')
  int? userId;

  factory MeetingParticipant.fromJson(Map<String, dynamic> json) {
    return MeetingParticipant(
      id: json['id'] as int,
      meetingId: json['meeting_id'] as int,
      email: json['email'] as String,
      userId: json['user_id'] != null ? json['user_id'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'email': email,
      'user_id': userId,
    };
  }
}
