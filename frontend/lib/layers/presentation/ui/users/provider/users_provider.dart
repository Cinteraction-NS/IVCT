
import 'dart:async';

import '../../../../domain/entities/user.dart';




List<User> _mockUsers =
    [
      User(
        id: "23",
        name: 'John Doe',
        email: 'john@test.com',
        imageUrl:
        'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
        createdAt: DateTime.now(),
      ),
    ];


User get _mockUser =>
    User(
        id: "24",
        name: 'John Doe',
        email: 'john@test.com',
        imageUrl:
        'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
        createdAt: DateTime.now(),
      );


class UsersProvider{
  UsersProvider();

  final _usersStream = StreamController<List<User>?>.broadcast();
  Stream<List<User>?> getUserStream() => _usersStream.stream;



  Future<void> getUsers() async {
    await _networkDelay();
    _usersStream.add(_mockUsers);
  }


  Future<void> addUser() async {
    // await _networkDelay();
    _mockUsers = [..._mockUsers, _mockUser];
    _usersStream.add(_mockUsers);
  }

  /// Simulate network delay
  Future<void> _networkDelay() async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }

}