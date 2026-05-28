import '../../repos/chat_repo.dart';

class LoadChats {
  LoadChats({required this.repo});

  final ChatRepo repo;

  call(int page, int paginate, String? search) {
    repo.loadChats(page, paginate, search);
  }
}
