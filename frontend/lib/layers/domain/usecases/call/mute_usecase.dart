import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';

import '../../repos/chat_repo.dart';

class CallMute {
  CallMute({required  this.repo});

  final CallRepo repo;

  call({required String kind, required bool muted}){
    repo.mute(kind: kind, muted: muted);
  }
}