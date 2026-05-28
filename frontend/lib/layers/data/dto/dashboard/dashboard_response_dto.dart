
import 'package:cinteraction_vc/layers/data/dto/dashboard/meetings_attended_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/dashboard/realized_meetings_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/dashboard/session_duration_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/dashboard/dashboard_response.dart';
import 'package:cinteraction_vc/layers/domain/entities/dashboard/realized_meetings.dart';

class DashboardResponseDto extends DashboardResponse{

  DashboardResponseDto({
    required super.meetingsAttended,
    required super.sessionDuration,
    required super.realizedMeetings
  });


  @override
  factory DashboardResponseDto.fromJson(Map<String, dynamic> json) =>
      DashboardResponseDto(
        meetingsAttended: MeetingsAttendedDto.fromJson(json['meetingsAttended']),
        realizedMeetings: RealizedMeetingsDto.fromJson(json['realized_meetings']),
        sessionDuration: SessionDurationDto.fromJson(json['session_duration'])
      );

}

