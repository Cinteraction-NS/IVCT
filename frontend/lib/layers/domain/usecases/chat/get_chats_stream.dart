import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_event.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';

class GetChatsStream {
  GetChatsStream({required this.repo});

  final ChatRepo repo;
  Stream<ChatEvent> call() {
    return repo.getChatsStream();
  }
}
