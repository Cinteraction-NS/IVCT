import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';

class GetLocalStream
{
  GetLocalStream({required  this.repo});

  final CallRepo repo;
  Stream<StreamRenderer> call()
  {
    return repo.getLocalStream();
  }
}