import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';

class MakeCall {
  MakeCall({required  this.repo});

  final CallRepo repo;

  call({required String toUser}){
    repo.makeCall(toUser);
  }
}