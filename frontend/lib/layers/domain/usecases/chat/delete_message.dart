import '../../repos/chat_repo.dart';

class DeleteMessage {
  DeleteMessage({required this.repo});

  final ChatRepo repo;

  call(int id) {
    repo.deleteMessage(id);
  }
}
