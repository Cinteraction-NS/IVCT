import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';
import 'package:cinteraction_vc/layers/domain/usecases/call/reject_call.dart';

import 'answer_call.dart';
import 'call_initialize.dart';
import 'get_local_stream.dart';
import 'get_remote_stream.dart';
import 'get_videocall_stream.dart';
import 'make_call.dart';
import 'mute_usecase.dart';

class CallUseCases {
  final CallRepo repo;

  CallUseCases({required this.repo})
      : makeCall = MakeCall(repo: repo),
        videoCallStream = GetVideoCallStream(repo: repo),
        rejectCall = RejectCall(repo: repo),
        getLocalStream = GetLocalStream(repo: repo),
        getRemoteStream = GetRemoteStream(repo: repo),
        answerCall = AnswerCall(repo: repo),
        initialize = CallInitialize(repo: repo),
        mute = CallMute(repo: repo);

  MakeCall makeCall;
  GetVideoCallStream videoCallStream;
  RejectCall rejectCall;
  GetLocalStream getLocalStream;
  GetRemoteStream getRemoteStream;
  AnswerCall answerCall;
  CallInitialize initialize;
  CallMute mute;
}
