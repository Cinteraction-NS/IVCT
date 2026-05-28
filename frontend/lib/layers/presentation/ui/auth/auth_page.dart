import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:cinteraction_vc/layers/presentation/ui/auth/sign_in_button/mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../core/navigation/route.dart';
import '../../../../../core/ui/input/input_field.dart';
import '../../../../../core/ui/widget/labeled_text_button.dart';
import '../../../../../core/ui/widget/loading_overlay.dart';
import '../../../../../core/ui/widget/responsive.dart';

import 'package:http/http.dart' as http;

import '../../cubit/auth/auth_cubit.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // bool _isSignUp = false;

  @override
  Widget build(BuildContext ctx) {
    String title = 'Log in';
    String checkboxTitle = 'Remember me';
    String changeLayoutTitle = 'Don’t have an account?';
    String changeLayoutAction = 'Sign up';
    String buttonText = 'Log In';

    void changeLayout() {
      ctx.read<AuthCubit>().changeLayout();

      _formKey.currentState?.reset();

      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();
      _emailController.clear();
    }


    void onAuthState(BuildContext context, AuthState state) {
      title = state.isSignUp ? 'Sign up' : 'Log in';
      checkboxTitle = state.isSignUp ? 'I agree to the Terms of Service' : 'Remember me';
      changeLayoutTitle = state.isSignUp
          ? 'Already have an account?'
          : 'Don’t have an account?';
      changeLayoutAction = state.isSignUp ? 'Sign in' : 'Sign up';
      buttonText = state.isSignUp ? 'Register' : 'Log In';


      if (state.registerSuccess) {
        _formKey.currentState?.reset();

        _passwordController.clear();
        _confirmPasswordController.clear();
        _nameController.clear();
        _emailController.clear();

        context.showSnackBarMessage(
          state.message ?? 'You successfully registered account',
          isError: false,
        );

        return;
      }

      if (state.loginSuccess) {
        // if (state.user != null) {
          AppRoute.home.go(context);
          // AppRoute.chat.go(context);
          return;
        // }
      }

      if (state.errorMessage!=null) {
        context.showSnackBarMessage(
          state.errorMessage!,
          isError: true,
        );
      }
    }

    void submit() {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      ctx.closeKeyboard();

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      ctx.read<AuthCubit>().submit(email, password, name, true);
    }

    return BlocConsumer<AuthCubit, AuthState>(
      listener: onAuthState,
      builder: (context, state) {

        final Widget body;
        if (context.isWide) {
          body = Material(
            child: Form(
              key: _formKey,
              child: Column(
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
                                  minWidth: 200, maxWidth: 550),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: context.titleTheme.headlineLarge,
                                  ),
                                  const SizedBox(height: 33),

                                  Visibility(
                                      visible: state.isSignUp,
                                      child: Column(
                                        children: [
                                          InputField.name(
                                              label: 'Enter your full name',
                                              controller: _nameController,
                                              textInputAction:
                                                  TextInputAction.next),
                                          const SizedBox(height: 16),
                                        ],
                                      )),

                                  InputField.email(
                                    label: 'Enter your email',
                                    controller: _emailController,
                                  ),

                                  const SizedBox(height: 16),
                                  InputField.password(
                                    label: 'Enter your password',
                                    controller: _passwordController,
                                    textInputAction:  state.isSignUp
                                        ? TextInputAction.next
                                        : TextInputAction.done,
                                    onFieldSubmitted:  state.isSignUp
                                        ? null
                                        : (_) => submit(),
                                  ),

                                  Visibility(
                                      visible:  state.isSignUp,
                                      child: Column(
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
                                      )),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTileTheme(
                                          horizontalTitleGap: 0.0,
                                          child: CheckboxListTile(
                                            contentPadding: EdgeInsets.zero,
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            title: Text(checkboxTitle),
                                            value: state.isChecked,
                                            onChanged: (bool? value) {
                                              ctx
                                                  .read<AuthCubit>()
                                                  .checkboxChangedState();
                                            },
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: !state.isSignUp,
                                        child: LabeledTextButton(
                                          label: 'Forgot password',
                                          action: '',
                                          onTap: () => {
                                            AppRoute.forgotPassword
                                                .push(context)
                                          },
                                        ),
                                      )
                                    ],
                                  ),

                                  const SizedBox(height: 8),



                                  SizedBox(
                                    width: double.maxFinite,
                                    child: ElevatedButton(
                                      onPressed: () => submit(),
                                      child: Text(buttonText),
                                    ),
                                  ),

                                  LabeledTextButton(
                                    label: "",
                                    action: "Privacy Policy",
                                    onTap: () =>{
                                      launchUrlString("https://cinteraction.com/privacy")
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // const Spacer(),

                                  // Row(
                                  //   children: [
                                  //     const Expanded(child: Divider()),
                                  //     Container(
                                  //       margin: const EdgeInsets.only(
                                  //           left: 5, right: 5),
                                  //       child: const Text('Or login with'),
                                  //     ),
                                  //     const Expanded(child: Divider()),
                                  //   ],
                                  // ),
                                  //
                                  // const SizedBox(height: 8),



                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //
                                  //     buildSignInButton(
                                  //      onPressed: () async {
                                  //         await context
                                  //            .read<AuthCubit>()
                                  //            .signInWithGoogle();
                                  //      }
                                  //     ),

                                      // SizedBox(
                                      //   width: 70,
                                      //   height: 60,
                                      //   child: OutlinedButton(
                                      //       onPressed: () => {
                                      //             context
                                      //                 .read<AuthCubit>()
                                      //                 .signInWithGoogle()
                                      //           },
                                      //       style: OutlinedButton.styleFrom(
                                      //         side: const BorderSide(
                                      //             width: 1,
                                      //             color: Color(0xFFBDBDBD)),
                                      //         shape: RoundedRectangleBorder(
                                      //           side: const BorderSide(
                                      //               width: 1,
                                      //               color: Color(0xFFBDBDBD)),
                                      //           borderRadius:
                                      //               BorderRadius.circular(18),
                                      //         ),
                                      //       ),
                                      //       child:
                                      //           imageSVGAsset('google_logo')),
                                      // ),
                                      // const SizedBox(width: 34),
                                      // SizedBox(
                                      //   width: 70,
                                      //   height: 60,
                                      //   child: OutlinedButton(
                                      //       onPressed: () => {
                                      //             context
                                      //                 .read<AuthCubit>()
                                      //                 .signInWithFacebook()
                                      //           },
                                      //       style: OutlinedButton.styleFrom(
                                      //         side: const BorderSide(
                                      //             width: 1,
                                      //             color: Color(0xFFBDBDBD)),
                                      //         shape: RoundedRectangleBorder(
                                      //           side: const BorderSide(
                                      //               width: 1,
                                      //               color: Color(0xFFBDBDBD)),
                                      //           borderRadius:
                                      //               BorderRadius.circular(18),
                                      //         ),
                                      //       ),
                                      //       child: imageSVGAsset('fb_logo')),
                                      // )


                                    // ],
                                  // ),

                                  const SizedBox(height: 8),
                                  LabeledTextButton(
                                    label: changeLayoutTitle,
                                    action: changeLayoutAction,
                                    onTap: () => changeLayout(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          body = SafeArea(
            child: ResponsiveLayout(
              body: Form(
                key: _formKey,
                child: Column(
                  children: [
                    imageSVGAsset('original_long_logo') as Widget,
                    Container(
                      width: 230,
                      height: 239,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: ImageAsset('login_image.png'),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.titleTheme.headlineLarge,
                    ),
                    const SizedBox(height: 33),

                    Visibility(
                        visible: state.isSignUp,
                        child: Column(
                          children: [
                            InputField.name(
                                label: 'Enter your full name',
                                controller: _nameController,
                                textInputAction: TextInputAction.next),
                            const SizedBox(height: 16),
                          ],
                        )),

                    InputField.email(
                      label: 'Enter your email',
                      controller: _emailController,
                    ),

                    const SizedBox(height: 16),
                    InputField.password(
                      label: 'Enter your password',
                      controller: _passwordController,
                      textInputAction:  state.isSignUp
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onFieldSubmitted:
                      state.isSignUp ? null : (_) => submit(),
                    ),

                    Visibility(
                        visible:  state.isSignUp,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            InputField(
                              label: 'Confirm password',
                              controller: _confirmPasswordController,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => submit(),
                              keyboardType: TextInputType.visiblePassword,
                              autofillHints: const [AutofillHints.password],
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
                        )),

                    Row(
                      children: [
                        Expanded(
                          child: ListTileTheme(
                            horizontalTitleGap: 0.0,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(checkboxTitle),
                              value: state.isChecked,
                              onChanged: (bool? value) {
                                ctx.read<AuthCubit>().checkboxChangedState();
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !state.isSignUp,
                          child: LabeledTextButton(
                            label: 'Forgot password',
                            action: '',
                            onTap: () =>
                                {AppRoute.forgotPassword.push(context)},
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: () => submit(),
                        child: Text(buttonText),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 16),
                    // const Spacer(),

                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: const Text('Or login with'),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 60,
                          child: OutlinedButton(
                              onPressed: () => {
                                    context.read<AuthCubit>().signInWithGoogle()
                                  },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    width: 1, color: Color(0xFFBDBDBD)),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1, color: Color(0xFFBDBDBD)),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: imageSVGAsset('google_logo')),
                        ),
                        // const SizedBox(width: 34),
                        // SizedBox(
                        //   width: 70,
                        //   height: 60,
                        //   child: OutlinedButton(
                        //       onPressed: () => {
                        //             context
                        //                 .read<AuthCubit>()
                        //                 .signInWithFacebook()
                        //           },
                        //       style: OutlinedButton.styleFrom(
                        //         side: const BorderSide(
                        //             width: 1, color: Color(0xFFBDBDBD)),
                        //         shape: RoundedRectangleBorder(
                        //           side: const BorderSide(
                        //               width: 1, color: Color(0xFFBDBDBD)),
                        //           borderRadius: BorderRadius.circular(18),
                        //         ),
                        //       ),
                        //       child: imageSVGAsset('fb_logo')),
                        // )
                      ],
                    ),

                    const SizedBox(height: 8),
                    LabeledTextButton(
                      label: changeLayoutTitle,
                      action: changeLayoutAction,
                      onTap: () => changeLayout(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: LoadingOverlay(
              loading: state.loading?? false,
              child: Container(
                color: Colors.white,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    // child:
                    // body,

                    child: state.isLogged
                        ? const Center(
                            child: Text('User is already logged in'),
                          )
                        : body,
                  ),
                ),
              )),
        );
      },
    );
  }
}
