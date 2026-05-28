import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';

class CallInitialize {
  CallInitialize({required  this.repo});

  final CallRepo repo;

  call(){
    repo.initialize();
  }
}