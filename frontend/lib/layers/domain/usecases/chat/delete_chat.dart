import '../../repos/chat_repo.dart';

class DeleteChat {
  DeleteChat({required this.repo});

  final ChatRepo repo;

  call(int chatId, int userId) {
    repo.deleteChat(chatId, userId);
  }
}
