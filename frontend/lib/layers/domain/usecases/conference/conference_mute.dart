
import '../../repos/conference_repo.dart';

class ConferenceMute  {
  ConferenceMute({required  this.repo});

  final ConferenceRepo repo;

  call(String kind, bool muted) {
    repo.mute(kind: kind, muted: muted);
  }
}
