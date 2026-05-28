import 'package:cinteraction_vc/core/app/injector.dart';

import '../../../data/dto/user_dto.dart';
import '../../entities/api_response.dart';
import '../../repos/auth_repo.dart';


class SetNewPassword{
  SetNewPassword();

  final AuthRepo _repo = getIt.get<AuthRepo>();

   Future<ApiResponse<bool?>> call(String email, String token, String newPassword) async{
    return await _repo.setNewPassword(email: email, token: token, newPassword: newPassword);
  }
}