import '../../repos/chat_repo.dart';

class LoadUsers {
  LoadUsers({required this.repo});

  final ChatRepo repo;

  call(int page, int paginate, int companyId, String? search) {
    repo.loadUsers(page, paginate, companyId, search);
  }
}
