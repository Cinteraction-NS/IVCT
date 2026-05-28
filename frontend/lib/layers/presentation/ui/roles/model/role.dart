

import 'package:cinteraction_vc/layers/presentation/ui/roles/model/permission.dart';

class Role {
  Role({
    required this.id,
    required this.name,
    required this.users,
    required this.permissions,
    required this.authorityLevel,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int users;
  final List<Permission> permissions;
  final int authorityLevel;
  final DateTime createdAt;
}