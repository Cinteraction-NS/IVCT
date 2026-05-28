import 'dart:async';

import '../../../../domain/entities/user.dart';
import '../model/group.dart';

List<User> get _mockUsers => [
      User(
        id: "23",
        name: 'John Doe',
        email: 'john@test.com',
        imageUrl:
            'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
        createdAt: DateTime.now(),
      ),
      User(
        id: "24",
        name: 'John Doe',
        email: 'john@test.com',
        imageUrl:
            'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
        createdAt: DateTime.now(),
      ),
    ];

User get _user => User(
      id: "25",
      name: 'John Doe',
      email: 'john@test.com',
      imageUrl:
          'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
      createdAt: DateTime.now(),
    );

List<Group> _mockGroups = [
  Group(id: 'srdjan', name: 'Video production II', userList: _mockUsers, )
];

Group get _mockGroup =>
    Group(id: 'group-id', name: 'Video production II', userList: _mockUsers);

class GroupsProvider {
  GroupsProvider();

  final _groupStream = StreamController<List<Group>>.broadcast();
  final _groupUsersStream = StreamController<List<User>>.broadcast();

  Stream<List<Group>> getGroupStream() => _groupStream.stream;

  Stream<List<User>> getUserGroupStream() => _groupUsersStream.stream;

  Future<void> getGroups() async {
    await _networkDelay();

    _groupStream.add(_mockGroups);
  }

  Future<void> getUsersOfGroup(String id) async {
    await _networkDelay();
    _groupUsersStream.add(_mockGroups.where((i) => i.id == id).first.userList);
  }

  Future<void> addGroup() async {
    // await _networkDelay();
    _mockGroups = [..._mockGroups, _mockGroup];

    _groupStream.add(_mockGroups);
  }

  Future<void> addUserToGroup(String id) async {
    // await _networkDelay();

    var group = _mockGroups.where((i) => i.id == id).first;

    group.userList = [...group.userList, _user];
    _groupUsersStream.add(group.userList);
  }

  /// Simulate network delay
  Future<void> _networkDelay() async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
