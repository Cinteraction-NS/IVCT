import 'package:cinteraction_vc/layers/data/dto/meetings/meeting_dto.dart';

import '../../entities/api_response.dart';
import '../../repos/conference_repo.dart';

class ConferenceStartCall {

  ConferenceStartCall({required  this.repo});

  final ConferenceRepo repo;

  Future<MeetingDto?> call() {
     return repo.startCall();
  }
}