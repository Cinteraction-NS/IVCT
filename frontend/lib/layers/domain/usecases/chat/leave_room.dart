import '../../repos/chat_repo.dart';

class LeaveRoom {
  LeaveRoom({required this.repo});

  final ChatRepo repo;

  call() {
    repo.leaveRoom();
  }
}
