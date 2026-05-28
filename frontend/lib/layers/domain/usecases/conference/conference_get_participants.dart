import '../../../../core/io/network/models/participant.dart';
import '../../repos/conference_repo.dart';

class ConferenceGetParticipants {

  ConferenceGetParticipants({required  this.repo});

  final ConferenceRepo repo;

  Future<List<Participant>> call() {
    return repo.getParticipants();
  }
}
