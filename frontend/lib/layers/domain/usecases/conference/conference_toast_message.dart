
import '../../../../core/janus/janus_client.dart';
import '../../../../core/util/util.dart';
import '../../repos/conference_repo.dart';

class ConferenceToastMessageStream {

  ConferenceToastMessageStream({required  this.repo});

  final ConferenceRepo repo;


  Stream<String> call() {
    return repo.getToastStream();
  }
}
