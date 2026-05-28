import '../../repos/chat_repo.dart';

class GetChatDetails {
  GetChatDetails({required this.repo});

  final ChatRepo repo;

  call(int id, int page) {
    repo.getChatDetails(id, page);
  }
}
