
import '../../../core/io/network/models/login_response.dart';
import '../../data/dto/user_dto.dart';
import '../entities/api_response.dart';
import '../entities/user.dart';

abstract class AuthRepo
{
  const AuthRepo();

  Future<ApiResponse<String>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required bool terms,
  });

  Future<ApiResponse<UserDto?>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<ApiResponse<UserDto?>> signWithGoogleAccount();

  Future<ApiResponse<UserDto?>> signWithFacebookAccount();
  Future<ApiResponse<UserDto?>> getUserDetails();
  Future<ApiResponse<bool?>> resetPassword({
    required String email,
  });

  Future<ApiResponse<bool?>> setNewPassword({
    required String email,
    required String token,
    required String newPassword,
  });

}