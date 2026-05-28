
import '../../repos/conference_repo.dart';

class ConferenceUnPublish {

  ConferenceUnPublish({required  this.repo});

  final ConferenceRepo repo;

  call() {
    repo.unPublish();
  }
}
