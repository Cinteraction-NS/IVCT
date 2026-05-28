import 'package:cinteraction_vc/layers/domain/entities/dashboard/meetings_attended.dart';
import 'package:cinteraction_vc/layers/domain/entities/dashboard/realized_meetings.dart';
import 'package:cinteraction_vc/layers/domain/entities/dashboard/session_duration.dart';
import 'package:json_annotation/json_annotation.dart';

class DashboardResponse {
  DashboardResponse(
      {required this.meetingsAttended,
      required this.sessionDuration,
      required this.realizedMeetings
      });

  final MeetingsAttended meetingsAttended;

  @JsonKey(name: 'session_duration')
  final SessionDuration sessionDuration;

  @JsonKey(name: 'realized_meetings')
  final RealizedMeetings realizedMeetings;
}
