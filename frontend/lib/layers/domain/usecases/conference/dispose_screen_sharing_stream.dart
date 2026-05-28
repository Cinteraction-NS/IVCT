
import '../../repos/conference_repo.dart';

class DisposeScreenSharingStream  {
  DisposeScreenSharingStream({required  this.repo});

  final ConferenceRepo repo;

  Stream<void> call() {
    return repo.getDisposeScreenSharingStream();
  }
}
