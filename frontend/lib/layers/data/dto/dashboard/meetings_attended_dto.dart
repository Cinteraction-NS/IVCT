import 'package:cinteraction_vc/layers/domain/entities/dashboard/meetings_attended.dart';

import 'attended_meeting_dto.dart';

class MeetingsAttendedDto extends MeetingsAttended{

  MeetingsAttendedDto({
    required int sum,
    required List<AttendedMeetingDto> meetings}) : super(sum: sum, meetings: meetings);

  @override
  factory MeetingsAttendedDto.fromJson(Map<String, dynamic> json) {
    var meetings = json["meetings"];

    // print('from json $meetings');
    return MeetingsAttendedDto(
        sum: json['sum'],
        meetings: List<AttendedMeetingDto>.from(meetings.map((e) => AttendedMeetingDto.fromJson(e)) ));
  }
}