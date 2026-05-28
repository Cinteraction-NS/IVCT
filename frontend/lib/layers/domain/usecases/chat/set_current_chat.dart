import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';

import '../../repos/chat_repo.dart';

class SetCurrentChat {
  SetCurrentChat({required this.repo});

  final ChatRepo repo;

  call(ChatDto? chat) {
    repo.setCurrentChat(chat);
  }
}
