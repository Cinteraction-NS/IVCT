import 'dart:async';

import 'package:cinteraction_vc/core/logger/loggy_types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../ui/groups/repository/groups_repository.dart';
import '../../ui/users/repository/users_repository.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> with BlocLoggy {
  UsersCubit({
    required this.usersRepository,
    required this.groupRepository,
  }) : super(const InitialUsersState()) {
    _load();
  }

  final UsersRepository usersRepository;
  final GroupsRepository groupRepository;

  StreamSubscription<List<User>?>? _usersSubscription;
  StreamSubscription<List<User>?>? _groupUsersSubscription;

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _groupUsersSubscription?.cancel();
    return super.close();
  }

  void _load() {
    _usersSubscription = usersRepository.getUsersStream().listen(_onUsers);
    _groupUsersSubscription =
        groupRepository.getUSerGroupsStream().listen(_onUsers);
  }

  void loadUsers() {
    emit(const UsersIsLoading());
    usersRepository.getListOfUsers();
  }

  void loadUsersOfGroup(String groupId) {
    emit(const UsersIsLoading());
    groupRepository.getListOfUsersOfGroup(groupId);
  }

  void _onUsers(List<User>? users) {
    loggy.info('list of users: ${users?.length}');
    emit(UsersLoaded(users: users));
  }

  Future<void> addUser() async {
    emit(const UsersIsLoading());
    usersRepository.addUser();
  }

  Future<void> addUserGroup(String id) async {
    emit(const UsersIsLoading());
    groupRepository.addUserGroup(id);
  }
}
