import '../../../../domain/entities/user.dart';
import '../provider/users_provider.dart';

class UsersRepository {
  UsersRepository({required this.usersProvider});

  final UsersProvider usersProvider;

  Stream<List<User>?> getUsersStream() {
    return usersProvider.getUserStream();
  }

  Future<void> getListOfUsers() async {
    usersProvider.getUsers();
  }

  Future<void> addUser() async {
    usersProvider.addUser();
  }
}
