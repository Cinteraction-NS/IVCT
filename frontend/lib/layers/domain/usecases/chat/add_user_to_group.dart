import '../../repos/chat_repo.dart';

class AddUserToGroup {
  AddUserToGroup({required this.repo});

  final ChatRepo repo;

  call(int chatId, int userId, List<int> participantIds) {
    repo.addUserOnGroupChat(chatId, userId, participantIds);
  }
}
