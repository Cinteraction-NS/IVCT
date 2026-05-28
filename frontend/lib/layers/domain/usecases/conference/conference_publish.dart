
import '../../repos/conference_repo.dart';

class ConferencePublish  {

  ConferencePublish({required  this.repo});

  final ConferenceRepo repo;

  call() {
    repo.publish();
  }
}
