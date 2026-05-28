import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/repos/home_repo.dart';

import '../../entities/meetings/meeting.dart';

class GetNextMeetingUseCase{
  GetNextMeetingUseCase({required this.repo});
  final HomeRepo repo;

  Future<ApiResponse<Meeting?>> call() {
    return repo.getNextMeeting();
  }
}