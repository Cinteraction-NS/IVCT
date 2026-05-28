import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/io/network/models/data_channel_command.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/layers/data/source/local/local_storage.dart';
import 'package:cinteraction_vc/layers/domain/source/api.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_state.dart';
import 'package:file_picker/file_picker.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState.initial()) {
    _loadUserFromApi();
    load();
  }

  void load() {}

  void loadUser() {
    final user = getIt.get<LocalStorage>().loadLoggedUser();
    if (user != null) {
      emit(state.copyWith(user: user));
    }
  }

  final api = getIt.get<Api>();

  Future<void> updateUser({
    PlatformFile? file,
    required User user,
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
    required BuildContext context,
  }) async {
    await api.updateUserProfile(
      file: file,
      user: user,
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    final updatedUser = await api.getUserDetails();
    getIt.get<LocalStorage>().saveLoggedUser(user: updatedUser.response!);
    emit(state.copyWith(user: updatedUser.response));
    context.showSnackBarMessage('Your profile has been successfully updated.');
  }

  Future<void> updateUserAfterImageChange(PlatformFile file) async {
    final currentUser = state.user;
    if (currentUser == null) return;
    await api.changeProfileImage(file: file, user: currentUser);
    final updatedUser = await api.getUserDetails();
    getIt.get<LocalStorage>().saveLoggedUser(user: updatedUser.response!);
    emit(state.copyWith(user: updatedUser.response));
  }

  Future<void> _loadUserFromApi() async {
    try {
      final response = await api.getUserDetails();
      final user = response.response;

      if (user != null) {
        getIt.get<LocalStorage>().saveLoggedUser(user: user);

        emit(state.copyWith(user: user));
      }
    } catch (e) {
      print('Failed to load user from API: $e');

      final user = getIt.get<LocalStorage>().loadLoggedUser();
      if (user != null) {
        emit(state.copyWith(user: user));
      }
    }
  }

  Future<void> fetchAndUpdateUser() async {
    print('UserChanged');
    final response = await getIt<Api>().getUserDetails();
    if (response.response != null) {
      final updatedUser = await api.getUserDetails();
      getIt.get<LocalStorage>().saveLoggedUser(user: updatedUser.response!);
      emit(state.copyWith(user: updatedUser.response));
    }
  }

  Future<void> changeUserStatus(UserStatus status) async {
    emit(state.copyWith(userStatus: status));
  }
}
