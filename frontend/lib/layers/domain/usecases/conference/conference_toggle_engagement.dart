
import '../../repos/conference_repo.dart';

class ConferenceToggleEngagement {

  ConferenceToggleEngagement({required  this.repo});

  final ConferenceRepo repo;

  call(bool enabled) {
    repo.toggleEngagement(enabled: enabled);
  }
}
