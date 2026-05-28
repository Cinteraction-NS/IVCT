import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';

import '../../repos/chat_repo.dart';

class GetUsersPaginationStream {
  GetUsersPaginationStream({required this.repo});

  final ChatRepo repo;

  Stream<UserListResponse> call() {
    return repo.getUsersPaginationStream();
  }
}
