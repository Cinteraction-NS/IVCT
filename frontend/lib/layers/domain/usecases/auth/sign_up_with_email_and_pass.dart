import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';

import '../../../data/dto/user_dto.dart';
import '../../repos/auth_repo.dart';


class SignUpWithEmailAndPassword{
  SignUpWithEmailAndPassword();

  final AuthRepo _repo = getIt.get<AuthRepo>();

  Future<ApiResponse<String>> call( String email,
       String password,
       String name,
       bool terms) async{
     return  await _repo.signUpWithEmailAndPassword(email: email, password: password, name: name, terms: terms);
  }
}