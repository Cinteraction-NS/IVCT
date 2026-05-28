

import '../../../../domain/entities/user.dart';
import '../model/group.dart';
import '../provider/groups_provider.dart';

class GroupsRepository{
  GroupsRepository({
    required this.groupsProvider
});

  final GroupsProvider groupsProvider;


  Stream<List<Group>> getGroupsStream() {
    return groupsProvider.getGroupStream();
  }

  Stream<List<User>> getUSerGroupsStream() {
    return groupsProvider.getUserGroupStream();
  }


  Future<void> getListOfGroups() async
  {
    groupsProvider.getGroups();
  }

  Future<void> getListOfUsersOfGroup(String id) async
  {
    groupsProvider.getUsersOfGroup(id);
  }


  Future<void> addGroup() async
  {
    groupsProvider.addGroup();
  }

  Future<void> addUserGroup(String id) async
  {
    groupsProvider.addUserToGroup(id);
  }

}