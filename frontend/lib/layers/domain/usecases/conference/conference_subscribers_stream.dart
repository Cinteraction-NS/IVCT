
import '../../../../core/io/network/models/participant.dart';
import '../../../../core/util/util.dart';
import '../../repos/conference_repo.dart';

class GetSubscriberStream
{
  GetSubscriberStream({required  this.repo});

  final ConferenceRepo repo;
  Stream<Map<dynamic, StreamRenderer>>   call()
  {
    return repo.getSubscribersStream();
  }
}