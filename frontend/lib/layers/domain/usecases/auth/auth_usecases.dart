
import 'package:cinteraction_vc/layers/domain/usecases/auth/reset_pass.dart';
import 'package:cinteraction_vc/layers/domain/usecases/auth/set_new_pass.dart';
import 'package:cinteraction_vc/layers/domain/usecases/auth/sign_in_with_email_and_pass.dart';
import 'package:cinteraction_vc/layers/domain/usecases/auth/sign_up_with_email_and_pass.dart';
import 'package:cinteraction_vc/layers/domain/usecases/auth/sign_up_with_google.dart';

import 'get_user_details.dart';

class AuthUseCases {
   SignUpWithGoogle signUpWithGoogle = SignUpWithGoogle();
   SignInWithEmailAndPassword signInWithEmailAndPassword = SignInWithEmailAndPassword();
   SignUpWithEmailAndPassword signUpWithEmailAndPassword = SignUpWithEmailAndPassword();
   GetUserDetails getUserDetails = GetUserDetails();
   ResetPassword resetPassword = ResetPassword();
   SetNewPassword setNewPassword = SetNewPassword();
}
