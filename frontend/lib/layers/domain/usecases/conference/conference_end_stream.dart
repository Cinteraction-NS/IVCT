
import '../../repos/conference_repo.dart';

class GetEndStream
{
  GetEndStream({required  this.repo});

  final ConferenceRepo repo;
  Stream<String> call()
  {
    return repo.getConferenceEndedStream();
  }
}