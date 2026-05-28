part of 'roles_cubit.dart';

@immutable
sealed class RoleState{
  const RoleState();
}

class InitialRoleState extends RoleState{
  const InitialRoleState();
}

class RolesLoaded extends RoleState{
  const RolesLoaded({required this.roles});
  final List<Role> roles;
}


class RolesIsLoading extends RoleState{
  const RolesIsLoading();
}

