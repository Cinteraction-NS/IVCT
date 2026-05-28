import '../../entities/api_response.dart';
import '../../repos/conference_repo.dart';

class ConferenceStopRecording {

  ConferenceStopRecording({required  this.repo});

  final ConferenceRepo repo;

  Future<void> call() {
     return repo.stopRecording();
  }
}