import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logger/loggy_types.dart';
import '../../../domain/entities/user.dart';
import '../../ui/profile/repository/profile_repository.dart';


part 'profile_state.dart';

// class ProfileCubit extends Cubit<ProfileState> with BlocLoggy {
//   ProfileCubit({
//     required this.userRepository,
//   }) : super(const ProfileInitial()) {
//     _load();
//   }
//
//   final ProfileRepository userRepository;
//
//   StreamSubscription<User?>? _userSubscription;
//
//   @override
//   Future<void> close() {
//     _userSubscription?.cancel();
//     return super.close();
//   }
//
//   void logOut() {
//     userRepository.logOut();
//   }
//
//   void _load() {
//     _userSubscription = userRepository.getUserStream().listen(_onUser);
//   }
//
//   void _onUser(User? user) {
//     loggy.info('new user: ${user?.id}');
//     emit(ProfileLoaded(user: user));
//   }
// }
