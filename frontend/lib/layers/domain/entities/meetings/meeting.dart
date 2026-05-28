import 'package:cinteraction_vc/layers/domain/entities/meetings/participant.dart';
import 'package:equatable/equatable.dart';

class Meeting extends Equatable {
  Meeting({
    required this.callId,
    this.chatId,
    required this.organizerId,
    required this.organizer,
    this.averageEngagement,
    this.averageDrowsiness,
    this.totalNumberOfUsers,
    this.recorded,
    required this.meetingStart,
    this.meetingEnd,
    this.streamId,
    this.eventName,
    this.eventDescription,
    this.scheduledAt,
    this.timezone,
    this.participantsEmails,
  });

  int callId;
  int? chatId;
  int organizerId;
  String organizer; // <- set manually after parsing if needed
  String? streamId;
  double? averageEngagement;
  double? averageDrowsiness;
  int? totalNumberOfUsers;
  bool? recorded;
  String? eventName;
  String? eventDescription;
  DateTime meetingStart;
  DateTime? meetingEnd;
  DateTime? scheduledAt;
  String? timezone;
  List<MeetingParticipant>? participantsEmails;

  String formatMeetingDuration() {
    if (meetingEnd == null) return '';
    final duration = meetingEnd!.difference(meetingStart);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}'
          '${minutes > 0 ? ' $minutes minute${minutes > 1 ? 's' : ''}' : ''}';
    } else {
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    }
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      callId: json['meeting_id'] as int,
      chatId: json['chat_id'] as int?,
      organizerId: json['organizer_id'] as int,
      organizer: '', // Set manually if needed
      streamId: json['stream_id'] as String?,
      averageEngagement: (json['average_engagement'] != null)
          ? (json['average_engagement'] as num).toDouble()
          : null,
      averageDrowsiness: (json['average_drowsiness'] != null)
          ? (json['average_drowsiness'] as num).toDouble()
          : null,
      totalNumberOfUsers: json['total_number_of_users'] as int?,
      recorded: json['recorded'] as bool?,
      eventName: json['event_name'] as String?,
      eventDescription: json['event_description'] as String?,
      meetingStart: DateTime.parse(json['meeting_start'] as String),
      meetingEnd: json['meeting_end'] != null
          ? DateTime.parse(json['meeting_end'] as String)
          : null,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      timezone: json['timezone'] as String?,
      participantsEmails: json['participants_emails'] != null
          ? (json['participants_emails'] as List)
              .map((e) => MeetingParticipant.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meeting_id': callId,
      'chat_id': chatId,
      'organizer_id': organizerId,
      'stream_id': streamId,
      'average_engagement': averageEngagement,
      'average_drowsiness': averageDrowsiness,
      'total_number_of_users': totalNumberOfUsers,
      'recorded': recorded,
      'event_name': eventName,
      'event_description': eventDescription,
      'meeting_start': meetingStart.toIso8601String(),
      'meeting_end': meetingEnd?.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'timezone': timezone,
      'participants_emails':
          participantsEmails?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        callId,
        chatId,
        organizerId,
        organizer,
        streamId,
        averageEngagement,
        averageDrowsiness,
        totalNumberOfUsers,
        recorded,
        eventName,
        eventDescription,
        meetingStart,
        meetingEnd,
        scheduledAt,
        timezone,
        participantsEmails,
      ];
}
