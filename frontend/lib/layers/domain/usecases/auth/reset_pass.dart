import 'package:cinteraction_vc/core/app/injector.dart';

import '../../../data/dto/user_dto.dart';
import '../../entities/api_response.dart';
import '../../repos/auth_repo.dart';


class ResetPassword{
  ResetPassword();

  final AuthRepo _repo = getIt.get<AuthRepo>();

   Future<ApiResponse<bool?>> call(String email) async{
    return await _repo.resetPassword(email: email);
  }
}