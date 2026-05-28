
import '../../repos/conference_repo.dart';

class ConferenceMuteById {

  ConferenceMuteById({required  this.repo});

  final ConferenceRepo repo;
  call(String id) {
    repo.muteById(id: id);
  }
}
