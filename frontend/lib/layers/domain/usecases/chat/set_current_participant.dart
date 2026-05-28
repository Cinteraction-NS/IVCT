import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';

import '../../repos/chat_repo.dart';

class SetCurrentParticipant {
  SetCurrentParticipant({required this.repo});

  final ChatRepo repo;

  call(UserDto user) {
    repo.setCurrentParticipant(user);
  }
}
