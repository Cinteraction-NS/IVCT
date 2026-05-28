import '../../entities/api_response.dart';
import '../../entities/meetings/meeting.dart';
import '../../entities/meetings/meeting_response.dart';
import '../../repos/meetings_repo.dart';

class GetPastMeetingsUseCase{

  GetPastMeetingsUseCase({required this.repo});
  final MeetingRepo repo;

  Future<ApiResponse<MeetingResponse?>> call(int page) {
    return repo.getListOfPastMeetings(page);
  }
}