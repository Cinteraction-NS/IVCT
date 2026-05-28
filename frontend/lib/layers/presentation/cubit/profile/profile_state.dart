part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
  });

  final User? user;
}
