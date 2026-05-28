
import '../../../../core/util/util.dart';
import '../../repos/conference_repo.dart';

class GetAvgEngagementStream
{
  GetAvgEngagementStream({required  this.repo});

  final ConferenceRepo repo;

  Stream<int> call()
  {
    return repo.getAvgEngagementStream();
  }
}