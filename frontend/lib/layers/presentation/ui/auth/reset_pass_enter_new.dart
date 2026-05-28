import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/ui/images/image.dart';
import '../../../../../core/ui/widget/responsive.dart';
import '../../../../core/navigation/route.dart';
import '../../../../core/ui/input/input_field.dart';
import '../../../../core/ui/widget/loading_overlay.dart';
import '../../cubit/auth/auth_cubit.dart';

class EnterNewPassword extends StatelessWidget{
  EnterNewPassword({super.key, required this.token, required this.email});

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final String token;
  final String email;


  void onAuthState(BuildContext context, AuthState state) {
    if (state.resetPassword ?? false) {
      AppRoute.auth.push(context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {

    void submit() {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      context.closeKeyboard();

      final password = _passwordController.text.trim();
      context.read<AuthCubit>().setNewPassword(email, token, password);
      //onSuccess
    }

    final Widget body;

    if(context.isWide)
      {
        body = Material(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.maxFinite,
                  alignment: Alignment.centerRight,
                  child: imageSVGAsset('original_long_logo'),
                ),
                Expanded(
                    flex: 1,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Image(
                              image: ImageAsset('login_image.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  height: double.maxFinite,
                                  constraints: const BoxConstraints(
                                      minWidth: 200, maxWidth: 520),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                   children: [
                                     Text('Create new Password',
                                       textAlign: TextAlign.center,
                                       style: context.titleTheme.headlineLarge,
                                     ),

                                     const SizedBox(height: 33),
                                     InputField.password(
                                       label: 'Enter your password',
                                       controller: _passwordController,
                                       textInputAction: TextInputAction.next,
                                       onFieldSubmitted:  null,
                                     ),

                                     Column(
                                           children: [
                                             const SizedBox(height: 16),
                                             InputField(
                                               label: 'Confirm password',
                                               controller:
                                               _confirmPasswordController,
                                               textInputAction:
                                               TextInputAction.done,
                                               onFieldSubmitted: (_) => submit(),
                                               keyboardType:
                                               TextInputType.visiblePassword,
                                               autofillHints: const [
                                                 AutofillHints.password
                                               ],
                                               validator: (confirmPassword) {
                                                 if (confirmPassword == null ||
                                                     confirmPassword.isEmpty) {
                                                   return 'Required';
                                                 }

                                                 if (_passwordController.text !=
                                                     confirmPassword) {
                                                   return 'Password doesn\'t match';
                                                 }
                                               },
                                             ),
                                           ],
                                         ),

                                     const SizedBox(height: 38),


                                     SizedBox(
                                       width: double.maxFinite,
                                       child:
                                       ElevatedButton(
                                         onPressed: ()=>{
                                           // AppRoute.auth.push(context)
                                           submit()
                                         },
                                         child: const Text('Set new Password'),
                                       ),
                                     ),

                                   ],
                                  ),
                                ),
                              ))
                        ])),
              ],
            ),
          ),
        );
      }
    else
      {
        body = SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ResponsiveLayout(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  imageSVGAsset('original_long_logo') as Widget,

                  Container(
                    width: 230,
                    height: 239,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: ImageAsset('reset_pass_check_mail.png'),
                        fit: BoxFit.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text('Check your mail',
                    textAlign: TextAlign.center,
                    style: context.titleTheme.headlineLarge,
                  ),

                  const SizedBox(height: 33),

                  Text('We have sent a password recover instructions to your email.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelMedium,
                  ),

                  const SizedBox(height: 38),

                  ElevatedButton(
                    onPressed: ()=>{
                      AppRoute.auth.push(context)
                    },
                    child: const Text('Ok'),
                  ),


                ],
              ),
            ),
          ),
        );
      }

    return BlocConsumer<AuthCubit, AuthState>(
        listener: onAuthState,
        builder: (context, state) {
             return Scaffold(
        body:  Container(
          color: Colors.white,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: body,
            ),
          ),
        ),
      );
        });

  }

  // void _submit(BuildContext context) {
  // }
}