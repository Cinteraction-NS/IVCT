
import '../../repos/conference_repo.dart';

class ConferenceSwitchCamera  {

  ConferenceSwitchCamera({required  this.repo});

  final ConferenceRepo repo;
  call() {
    repo.switchCamera();
  }
}
