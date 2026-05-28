import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';

class RejectCall {
  RejectCall({required  this.repo});

  final CallRepo repo;

  call(String from){
    repo.rejectCall(from);
  }
}