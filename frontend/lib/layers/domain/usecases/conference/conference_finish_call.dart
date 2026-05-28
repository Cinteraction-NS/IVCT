
import '../../repos/conference_repo.dart';

class ConferenceFinishCall{

  ConferenceFinishCall({required  this.repo});

  final ConferenceRepo repo;

  call() {
    repo.finishCall();
  }
}
