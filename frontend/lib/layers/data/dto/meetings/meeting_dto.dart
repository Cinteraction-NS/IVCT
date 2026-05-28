import 'package:cinteraction_vc/layers/domain/entities/meetings/meeting.dart';

import '../../../domain/entities/meetings/organizer.dart';

class MeetingDto extends Meeting {
  MeetingDto(
      {required super.callId,
      super.chatId,
      required super.organizerId,
      required super.organizer,
      super.averageEngagement,
      super.totalNumberOfUsers,
      super.recorded,
      required super.meetingStart,
      super.meetingEnd,
      super.streamId,
      super.eventName});

  @override
  factory MeetingDto.fromJson(Map<String, dynamic> json) => MeetingDto(
        callId: json['meeting_id'] as int,
        chatId: json['chat_id'] as int?,
        organizerId: json['organizer']['id'] as int,
        organizer: json['organizer']['name'] as String,
        averageEngagement: (json['average_engagement'] as num?)?.toDouble(),
        totalNumberOfUsers: json['total_number_of_users'] as int?,
        recorded: json['recorded'] as bool?,
        meetingStart: DateTime.parse(json['meeting_start'] as String),
        meetingEnd: json['meeting_end'] == null
            ? null
            : DateTime.parse(json['meeting_end'] as String),
        streamId: json['stream_id'] as String?,
        eventName: json['event_name'] as String?,
      );
}
