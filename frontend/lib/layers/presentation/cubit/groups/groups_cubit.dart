import 'dart:async';

import 'package:cinteraction_vc/core/logger/loggy_types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../ui/groups/model/group.dart';
import '../../ui/groups/repository/groups_repository.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> with BlocLoggy{
  GroupsCubit({
    required this.groupRepository,
  }) : super(const InitialGroupsState()) {
    _load();
  }

  final GroupsRepository groupRepository;

  StreamSubscription<List<Group>?>? _groupSubscription;



  @override
  Future<void> close() {
    _groupSubscription?.cancel();
    return super.close();
  }


  void _load() {
    _groupSubscription = groupRepository.getGroupsStream().listen(_onGroups);
  }

  void loadGroups() {
    emit(const GroupsIsLoading());
    groupRepository.getListOfGroups();
  }

  void showDetails(Group group)
  {
    emit(GroupDetails(group: group));
  }


  void _onGroups(List<Group> groups) {
    loggy.info('list of users: ${groups.length}');
    emit(GroupsLoaded(groups: groups));
  }

  Future<void> addGroup() async {
    emit(const GroupsIsLoading());
    groupRepository.addGroup();
  }

}