import '../../repos/chat_repo.dart';

class MessageSeen {
  MessageSeen({required this.repo});

  final ChatRepo repo;

  call({required int msgId}) {
    repo.messageSeen(msgId);
  }
}
