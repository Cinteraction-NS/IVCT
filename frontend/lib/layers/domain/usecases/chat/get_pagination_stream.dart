import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';

import '../../repos/chat_repo.dart';

class GetPaginationStream {
  GetPaginationStream({required this.repo});

  final ChatRepo repo;

  Stream<ChatPagination> call() {
    return repo.getPaginationStream();
  }
}
