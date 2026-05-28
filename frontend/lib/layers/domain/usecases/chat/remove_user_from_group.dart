import '../../repos/chat_repo.dart';

class RemoveUserFromGroup {
  RemoveUserFromGroup({required this.repo});

  final ChatRepo repo;

  call(int chatId, int userId) {
    repo.removeUserFromGroup(chatId, userId);
  }
}
