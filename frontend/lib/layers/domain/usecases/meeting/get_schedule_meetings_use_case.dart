import '../../entities/api_response.dart';
import '../../entities/meetings/meeting.dart';
import '../../repos/meetings_repo.dart';

class GetScheduleMeetings{
  final MeetingRepo repo;
  GetScheduleMeetings({required this.repo});

  Future<ApiResponse<List<Meeting>?>>  call() {
    return repo.getListOfScheduledMeetings();
  }
}