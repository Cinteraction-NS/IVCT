
import '../../repos/conference_repo.dart';

class ConferenceHandUp  {
  ConferenceHandUp({required  this.repo});

  final ConferenceRepo repo;

  call(bool handUp) {
    repo.handUp(handUp: handUp);
  }
}
