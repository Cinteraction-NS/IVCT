
import 'dart:async';
import 'dart:math';

import '../model/role.dart';


List<Role>  _mockRoles =
    [
      Role(id: '1', name: 'Super Admin', users: Random().nextInt(50), permissions: [], authorityLevel: 3, createdAt: DateTime.now()),
      Role(id: '2', name: 'Admin', users: Random().nextInt(50),  permissions: [], authorityLevel: 3, createdAt: DateTime.now()),
      Role(id: '3', name: 'Team Admin', users: Random().nextInt(50),  permissions: [], authorityLevel: 2, createdAt: DateTime.now()),
      Role(id: '4', name: 'User', users: Random().nextInt(50),  permissions: [], authorityLevel: 1, createdAt: DateTime.now()),
      Role(id: '5', name: 'Team User',  users: Random().nextInt(50), permissions: [], authorityLevel: 1, createdAt: DateTime.now()),
    ];


Role get _mockRole => Role(id: '1', name: 'Super Admin', users: Random().nextInt(50),permissions: [], authorityLevel: 3, createdAt: DateTime.now());
    // Group(id: 'group-id', name: 'Video production II', userList: _mockUsers);


class RolesProvider{
  RolesProvider();

  final _roleStream = StreamController<List<Role>>.broadcast();
  Stream<List<Role>> getRoleStream() => _roleStream.stream;


  Future<void> getRoles() async {
    await _networkDelay();
    _roleStream.add(_mockRoles);
  }


  Future<void> addRole() async {
    // await _networkDelay();
    _mockRoles = [..._mockRoles, _mockRole];
    _roleStream.add(_mockRoles);
  }

  /// Simulate network delay
  Future<void> _networkDelay() async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }

}