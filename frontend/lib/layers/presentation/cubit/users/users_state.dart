part of 'users_cubit.dart';

@immutable
sealed class UsersState {
  const UsersState();
}

class InitialUsersState extends UsersState {
  const InitialUsersState();
}

class UsersLoaded extends UsersState {
  const UsersLoaded({required this.users});
  final List<User>? users;
}

class UsersIsLoading extends UsersState {
  const UsersIsLoading();
}
