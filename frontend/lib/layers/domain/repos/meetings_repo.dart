import 'package:cinteraction_vc/layers/domain/entities/meetings/meeting.dart';

import '../entities/api_response.dart';
import '../entities/meetings/meeting_response.dart';

abstract class MeetingRepo {
  MeetingRepo();

  Future<ApiResponse<MeetingResponse?>> getListOfPastMeetings(int page);
  Future<ApiResponse<List<Meeting>?>>  getListOfScheduledMeetings();
}
