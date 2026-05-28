
import '../../../core/janus/janus_client.dart';
import '../../../core/util/util.dart';

abstract class CallRepo
{
  const CallRepo();

  Future<void> initialize();
  Future<void> makeCall(String user);
  Future<void> answerCall();
  Future<void> rejectCall(String from);
  Future<void> mute({required String kind, required bool muted});

  Stream<Result> getVideoCallStream();
  Stream<StreamRenderer> getLocalStream();
  Stream<StreamRenderer> getRemoteStream();

}