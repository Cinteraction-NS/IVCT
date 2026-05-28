import '../../repos/chat_repo.dart';

class GetChatDetailsByParticipiant {
  GetChatDetailsByParticipiant({required this.repo});

  final ChatRepo repo;

  call(int id, int page) {
    repo.getChatDetailsByParticipiant(id, page);
  }
}
