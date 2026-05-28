import 'package:cinteraction_vc/layers/data/dto/chat/user_event.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';

import '../../../../core/io/network/models/participant.dart';

class GetUsersStream {
  GetUsersStream({required this.repo});

  final ChatRepo repo;
  Stream<UserEvent> call() {
    return repo.getUsersStream();
  }
}
