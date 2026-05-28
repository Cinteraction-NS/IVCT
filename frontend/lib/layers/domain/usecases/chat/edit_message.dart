import '../../repos/chat_repo.dart';

class EditMessage {
  EditMessage({required this.repo});

  final ChatRepo repo;

  call(int id, String message) {
    repo.editMessage(id, message);
  }
}
