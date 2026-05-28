
import '../../repos/conference_repo.dart';

class ConferencePing {

  ConferencePing({required  this.repo});

  final ConferenceRepo repo;

  call(String msg) {
    repo.ping(msg: msg);
  }
}
