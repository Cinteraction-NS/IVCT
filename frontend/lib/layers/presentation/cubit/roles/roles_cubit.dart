import 'dart:async';

import 'package:cinteraction_vc/core/logger/loggy_types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../ui/roles/model/role.dart';
import '../../ui/roles/repository/roles_repository.dart';

part 'roles_state.dart';

class RolesCubit extends Cubit<RoleState> with BlocLoggy{
  RolesCubit({
    required this.roleRepository,
  }) : super(const InitialRoleState()) {
    _load();
  }

  final RolesRepository roleRepository;

  StreamSubscription<List<Role>?>? _groupSubscription;


  @override
  Future<void> close() {
    _groupSubscription?.cancel();
    return super.close();
  }


  void _load() {
    _groupSubscription = roleRepository.getRolesStream().listen(_onRoles);
  }

  void loadRoles() {
    emit(const RolesIsLoading());
    roleRepository.getListOfRoles();
  }


  void _onRoles(List<Role> groups) {
    loggy.info('list of users: ${groups.length}');
    emit(RolesLoaded(roles: groups));
  }

  Future<void> addRole() async {
    emit(const RolesIsLoading());
    roleRepository.addRole();
  }


}