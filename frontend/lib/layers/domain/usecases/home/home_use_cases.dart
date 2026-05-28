import 'package:cinteraction_vc/layers/domain/repos/home_repo.dart';
import 'package:cinteraction_vc/layers/domain/usecases/home/schedule_meeting_use_case.dart';

import 'get_next_meeting_use_case.dart';

class HomeUseCases {
  final HomeRepo repo;

  ScheduleMeetingUseCase scheduleMeetingUseCase;
  GetNextMeetingUseCase getNextMeetingUseCase;

  HomeUseCases({required this.repo})
      : scheduleMeetingUseCase = ScheduleMeetingUseCase(repo: repo),
        getNextMeetingUseCase = GetNextMeetingUseCase(repo: repo);
}
