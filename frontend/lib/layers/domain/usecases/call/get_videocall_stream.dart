import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../../core/janus/janus_client.dart';
import '../../entities/chat_message.dart';

class GetVideoCallStream
{
  GetVideoCallStream({required  this.repo});

  final CallRepo repo;
  Stream<Result> call()
  {
    return repo.getVideoCallStream();
  }
}