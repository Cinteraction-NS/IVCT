import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';

class UserEvent {
  final List<UserDto> users;
  final bool isSearch;

  UserEvent({required this.users, required this.isSearch});
}
