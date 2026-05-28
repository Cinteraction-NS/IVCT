part of 'groups_cubit.dart';

@immutable
sealed class GroupsState{
  const GroupsState();
}

class InitialGroupsState extends GroupsState{
  const InitialGroupsState();
}

class GroupsLoaded extends GroupsState{
  const GroupsLoaded({required this.groups});
  final List<Group> groups;
}

class GroupDetails extends GroupsState
{
  const GroupDetails({required this.group});
  final Group group;
}

class GroupsIsLoading extends GroupsState{
  const GroupsIsLoading();
}

