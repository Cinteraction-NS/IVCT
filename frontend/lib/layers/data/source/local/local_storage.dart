import 'dart:convert';

import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../dto/user_dto.dart';

abstract class LocalStorage {
  Future<bool> saveLoggedUser({required UserDto user});
  User? loadLoggedUser();
  Future<void> clearUser();
  Future<bool> saveRoomId({required String roomId});
  String? getRoomId();
  Future<void> clearRoomId();
}

class LocalStorageImpl extends LocalStorage {
  LocalStorageImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPref = sharedPreferences;

  final SharedPreferences _sharedPref;

  @override
  User? loadLoggedUser() {
    final jsonString = _sharedPref.getString('user');
    if (jsonString != null) {
      var userMap = json.decode(jsonString);
      try {
        var user = UserDto.fromJson(userMap);
        return user;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> saveLoggedUser({required UserDto user}) {
    print("==============");
    // print(user.id.substring(5));
    return _sharedPref.setString('user', json.encode(user.toJson()));
  }

  @override
  Future<void> clearUser() async {
    _sharedPref.remove('user');
  }

  @override
  String? getRoomId() {
    return _sharedPref.getString('roomId');
  }

  @override
  Future<bool> saveRoomId({required String roomId}) {
    return _sharedPref.setString('roomId', roomId);
  }

  @override
  Future<void> clearRoomId() async {
    _sharedPref.remove('roomId');
  }
}
