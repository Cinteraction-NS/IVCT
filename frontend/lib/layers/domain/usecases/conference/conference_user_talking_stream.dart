
import '../../repos/conference_repo.dart';

class GetUserTalkingStream
{
  GetUserTalkingStream({required  this.repo});

  final ConferenceRepo repo;
  Stream<void> call()
  {
    return repo.getUserTalkingStream();
  }
}