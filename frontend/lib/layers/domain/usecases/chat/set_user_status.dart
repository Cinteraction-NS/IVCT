import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/users/users_cubit.dart';

import '../../../../core/io/network/models/data_channel_command.dart';
import '../../repos/chat_repo.dart';

class SetUserStatus {
  SetUserStatus({required this.repo});

  final ChatRepo repo;

  call(String status) {
    repo.setUserStatus(status);
  }
}
