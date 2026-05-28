import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';

import '../../../../core/io/network/models/participant.dart';

class GetParticipantsStream
{
  GetParticipantsStream({required  this.repo});

  final ChatRepo repo;
  Stream<List<Participant>>  call()
  {
    return repo.getParticipantsStream();
  }
}