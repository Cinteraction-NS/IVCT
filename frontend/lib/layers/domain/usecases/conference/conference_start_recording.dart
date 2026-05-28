import '../../entities/api_response.dart';
import '../../repos/conference_repo.dart';

class ConferenceStartRecording {

  ConferenceStartRecording({required  this.repo});

  final ConferenceRepo repo;

  Future<bool> call()  {
     return repo.startRecording();
  }
}