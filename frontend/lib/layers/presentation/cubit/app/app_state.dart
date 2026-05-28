import 'package:cinteraction_vc/core/io/network/models/data_channel_command.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class AppState extends Equatable {
  final UserStatus userStatus;
  final User? user;

  const AppState({
    required this.userStatus,
    required this.user,
  });

  const AppState.initial({
    UserStatus userStatus = UserStatus.offline,
    User? user,
  }) : this(
          userStatus: userStatus,
          user: user,
        );

  AppState copyWith({
    UserStatus? userStatus,
    User? user,
  }) {
    return AppState(
      userStatus: userStatus ?? this.userStatus,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        userStatus,
        user,
      ];
}
