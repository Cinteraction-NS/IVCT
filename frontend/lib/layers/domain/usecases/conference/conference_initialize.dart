
import '../../repos/conference_repo.dart';

class ConferenceInitialize {
  ConferenceInitialize({required  this.repo});

  final ConferenceRepo repo;

  call({required int roomId, required String displayName}){
    repo.initialize(roomId: roomId, displayName: displayName);
  }
}