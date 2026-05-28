
import '../../repos/conference_repo.dart';

class ConferencePublishById {

  ConferencePublishById({required  this.repo});

  final ConferenceRepo repo;
  call(String id) {
    repo.publishById(id: id);
  }
}
