import 'package:cinteraction_vc/layers/domain/usecases/meeting/get_past_meetings_use_case.dart';
import 'package:cinteraction_vc/layers/domain/usecases/meeting/get_schedule_meetings_use_case.dart';

import '../../repos/meetings_repo.dart';

class MeetingUseCases{

  final MeetingRepo repo;

  GetPastMeetingsUseCase getPastMeetingsUseCase;
  GetScheduleMeetings getScheduleMeetings;

  MeetingUseCases({required this.repo}):
    getPastMeetingsUseCase = GetPastMeetingsUseCase(repo: repo),
    getScheduleMeetings = GetScheduleMeetings(repo: repo);
}