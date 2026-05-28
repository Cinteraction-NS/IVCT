

import '../../../../domain/entities/user.dart';

class Group {

  Group({
    required this.id,
    required this.name,
    required  this.userList
  }) : createdAt = DateTime.now();

  final String id;
  final String name;
  late final List<User> userList;
  DateTime? createdAt;
}