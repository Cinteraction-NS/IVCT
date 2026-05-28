import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';


class GetRemoteStream
{
  GetRemoteStream({required  this.repo});

  final CallRepo repo;
  Stream<StreamRenderer> call()
  {
    return repo.getRemoteStream();
  }
}