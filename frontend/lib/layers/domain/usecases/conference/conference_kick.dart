
import '../../repos/conference_repo.dart';

class ConferenceKick  {

  ConferenceKick({required  this.repo});

  final ConferenceRepo repo;

  call(String id) {
    repo.kick(id: id);
  }
}
