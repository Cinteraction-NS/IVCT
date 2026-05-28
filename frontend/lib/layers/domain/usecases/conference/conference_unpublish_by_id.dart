
import '../../repos/conference_repo.dart';

class ConferenceUnPublishById {

  ConferenceUnPublishById({required  this.repo});

  final ConferenceRepo repo;
  call(String id) {
    repo.unPublishById(id: id);
  }
}
