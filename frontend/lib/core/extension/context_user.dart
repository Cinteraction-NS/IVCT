import 'package:flutter/material.dart';
import '../../layers/data/source/local/local_storage.dart';
import '../../layers/domain/entities/user.dart';
import '../app/injector.dart';




extension BuildContextUserExt on BuildContext {
  User? get getCurrentUser {
    User? user = getIt.get<LocalStorage>().loadLoggedUser();
    return user;
  }
}
