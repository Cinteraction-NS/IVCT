part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState(
      {required this.isLogged,
      required this.loginSuccess,
      required this.registerSuccess,
      required this.isSignUp,
      this.loading,
      required this.isChecked,
      this.errorMessage,
      this.message,
      this.resetPassword});

  @override
  List<Object?> get props => [isSignUp, loading, isChecked, isLogged];

  final bool loginSuccess;
  final bool registerSuccess;
  final bool isSignUp;
  final bool isLogged;
  final bool? loading;
  final bool isChecked;
  final String? errorMessage;
  final String? message;
  final bool? resetPassword;

  const AuthState.initial({
    bool isLogged = false,
    bool loginSuccess = false,
    bool registerSuccess = false,
    bool isSignUp = false,
    bool loading = false,
    bool isChecked = false,
    bool resetPassword = false,
  }) : this(
            isLogged: isLogged,
            isSignUp: isSignUp,
            loading: loading,
            isChecked: isChecked,
            loginSuccess: loginSuccess,
            registerSuccess: registerSuccess,
            resetPassword: resetPassword);

  const AuthState.register({
    bool isLogged = false,
    bool loginSuccess = false,
    bool registerSuccess = false,
    bool isSignUp = true,
    bool loading = false,
    bool isChecked = false,
    bool resetPassword = false,
  }) : this(
            isLogged: isLogged,
            isSignUp: isSignUp,
            loading: loading,
            isChecked: isChecked,
            loginSuccess: loginSuccess,
            registerSuccess: registerSuccess,
            resetPassword: resetPassword);

  const AuthState.loginSuccess({
    bool isLogged = false,
    bool loginSuccess = true,
    bool registerSuccess = false,
    bool isSignUp = false,
    bool loading = false,
    bool isChecked = false,
    bool resetPassword = false,
  }) : this(
            isLogged: isLogged,
            isSignUp: isSignUp,
            loading: loading,
            isChecked: isChecked,
            loginSuccess: loginSuccess,
            registerSuccess: registerSuccess,
            resetPassword: resetPassword);

  const AuthState.registerSuccess(
      {bool isLogged = false,
      bool loginSuccess = false,
      bool registerSuccess = true,
      bool isSignUp = false,
      bool loading = false,
      bool isChecked = false,
      bool resetPassword = false,
      String? message})
      : this(
            isLogged: isLogged,
            isSignUp: isSignUp,
            loading: loading,
            isChecked: isChecked,
            loginSuccess: loginSuccess,
            registerSuccess: registerSuccess,
            resetPassword: resetPassword,
            message: message
  );

  AuthState copyWith(
      {bool? isSignUp,
      bool? loading,
      bool? isChecked,
      String? errorMessage,
      bool? isLogged,
      bool? resetPassword}) {
    return AuthState(
        isLogged: isLogged ?? this.isLogged,
        isSignUp: isSignUp ?? this.isSignUp,
        resetPassword: resetPassword ?? false,
        loading: loading,
        isChecked: isChecked ?? this.isChecked,
        errorMessage: errorMessage,
        loginSuccess: loginSuccess,
        registerSuccess: registerSuccess);
  }

  AuthState error({String? errorMessage}) {
    return AuthState(
        isLogged: false,
        isSignUp: isSignUp,
        loading: false,
        isChecked: isChecked,
        errorMessage: errorMessage,
        loginSuccess: loginSuccess,
        registerSuccess: registerSuccess);
  }
}
