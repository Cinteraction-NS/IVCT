import 'package:cinteraction_vc/layers/domain/entities/meetings/meeting.dart';
import 'package:json_annotation/json_annotation.dart';

class MeetingResponse{

  MeetingResponse({required this.meetings, required this.lastPage});

  @JsonKey(name: 'data')
  List<Meeting> meetings;

  @JsonKey(name: 'last_page')
  int lastPage;
}