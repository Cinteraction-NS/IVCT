import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';

import '../../repos/chat_repo.dart';

class AnswerCall {
  AnswerCall({required  this.repo});

  final CallRepo repo;

  call(){
    repo.answerCall();
  }
}