
import '../../../../../core/app/injector.dart';
import '../../../data/dto/user_dto.dart';
import '../../entities/api_response.dart';
import '../../entities/user.dart';
import '../../repos/auth_repo.dart';

class SignUpWithGoogle{
   SignUpWithGoogle();

   final AuthRepo _repo = getIt.get<AuthRepo>();

   Future<ApiResponse<UserDto?>> call() async{
    return await _repo.signWithGoogleAccount();
  }
}