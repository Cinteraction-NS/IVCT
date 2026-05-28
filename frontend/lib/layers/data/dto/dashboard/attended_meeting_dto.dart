import 'package:cinteraction_vc/layers/domain/entities/dashboard/attended_meeting.dart';

class AttendedMeetingDto extends AttendedMeeting {
  AttendedMeetingDto({required super.date, required super.value});

  @override
  factory AttendedMeetingDto.fromJson(Map<String, dynamic> json) =>
      AttendedMeetingDto(
          date: json['date'] as String, value: json['value'] as int);
}
