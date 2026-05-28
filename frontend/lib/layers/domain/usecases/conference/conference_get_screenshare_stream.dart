
import '../../../../core/util/util.dart';
import '../../repos/conference_repo.dart';

class GetScreenShareStream
{
  GetScreenShareStream({required  this.repo});

  final ConferenceRepo repo;

  Stream<Map<dynamic, StreamRenderer>> call()
  {
    return repo.getConferenceScreenShareStream();
  }
}