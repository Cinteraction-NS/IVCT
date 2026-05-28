import 'package:cinteraction_vc/layers/domain/entities/dashboard/realized_meetings.dart';

class RealizedMeetingsDto extends RealizedMeetings {
  RealizedMeetingsDto({super.realized = 0, super.missed = 0});

  @override
  factory RealizedMeetingsDto.fromJson(Map<String, dynamic> json) => RealizedMeetingsDto(missed: json['missed'] as int, realized: json['realized'] as int);

}
