import 'dart:async';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/util/secure_local_storage.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logger/loggy_types.dart';
import '../../../data/source/local/local_storage.dart';
import '../../../domain/usecases/auth/auth_usecases.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> with BlocLoggy {
  AuthCubit({
    required AuthUseCases authUseCases,
  })  : _authUseCases = authUseCases,
        super(const AuthState.initial()) {
    _init();
  }

  final AuthUseCases _authUseCases;

  void _init() async {
    var accessToken = await getAccessToken();

    if (accessToken != null) {
      print('access token: $accessToken');
      var response = await _authUseCases.getUserDetails();

      _successLogin(response);
    }
  }

  Future<void> signUpWithEmailAndPassword(
      {required String email,
      required String password,
      required String name,
      required bool terms}) async {
    emit(state.copyWith(loading: true));

    final response = await _authUseCases.signUpWithEmailAndPassword(
        email, password, name, true);
    if (response.response != null) {
      emit(AuthState.registerSuccess(message: response.response));
    } else {
      emit(state.error(errorMessage: response.error!.errorMessage));
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(loading: true));

    try {
      final response =
          await _authUseCases.signInWithEmailAndPassword(email, password);
      _successLogin(response);
    } catch (e, s) {
      emit(state.error(errorMessage: 'errorMessage ${e.toString()}'));
    }
  }

  _successLogin(ApiResponse<UserDto?> response) {
    if (response.error != null) {
      emit(state.error(errorMessage: response.error!.errorMessage));
      return;
    }
    var user = response.response;
    if (user == null) {
      emit(state.error(errorMessage: 'User is null'));
      return;
    }

    // if (user.emailVerifiedAt == null) {
    //   emit(state.error(errorMessage: 'Email is not verified'));
    //   return;
    // }

    getIt.get<LocalStorage>().saveLoggedUser(user: user);
    emit(const AuthState.loginSuccess());
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(loading: true));
    try {
      final response = await _authUseCases.signUpWithGoogle();

      _successLogin(response);
    } catch (e, s) {
      loggy.error('signInWithGoogle error', e, s);
      emit(state.error(errorMessage: e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(state.copyWith(loading: true));
    try {
      final response = await _authUseCases.resetPassword(email);
      emit(state.copyWith(resetPassword: true));
    } catch (e, s) {
      loggy.error('signInWithGoogle error', e, s);
      emit(state.error(errorMessage: e.toString()));
    }
  }

  Future<void> signInWithFacebook() async {
    emit(state.error(errorMessage: 'Not implemented yet'));
  }

  void checkboxChangedState() {
    emit(state.copyWith(isChecked: !state.isChecked));
  }

  void changeLayout() {
    if (state.isSignUp) {
      emit(const AuthState.initial());
    } else {
      emit(const AuthState.register());
    }
  }

  void setNewPassword(String email, String token, String password) async {
    emit(state.copyWith(loading: true));

    try {
      final response =
          await _authUseCases.setNewPassword(email, token, password);
      emit(state.copyWith(resetPassword: true));
    } catch (e, s) {
      loggy.error('signInWithGoogle error', e, s);
      emit(state.error(errorMessage: e.toString()));
    }
  }

  void submit(String mail, String password, String name, bool terms) {
    if (state.isSignUp) {
      signUpWithEmailAndPassword(
          email: mail, password: password, name: name, terms: terms);
    } else {
      signInWithEmailAndPassword(
        email: mail,
        password: password,
      );
    }
  }
}
