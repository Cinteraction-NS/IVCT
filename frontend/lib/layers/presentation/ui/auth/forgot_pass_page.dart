import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/ui/images/image.dart';
import '../../../../../core/ui/input/input_field.dart';
import '../../../../../core/ui/widget/responsive.dart';
import '../../../../core/ui/widget/loading_overlay.dart';
import '../../cubit/auth/auth_cubit.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    void onAuthState(BuildContext context, AuthState state) {
      if (state.resetPassword ?? false) {
        AppRoute.forgotPasswordSuccess.go(context);
        return;
      }
    } // AppRoute.forgotPasswordSuccess.push(context)

    return BlocConsumer<AuthCubit, AuthState>(
        listener: onAuthState,
        builder: (context, state) {
          final Widget body;

          if (context.isWide) {
            body = Column(
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
                                image: ImageAsset('reset_pass_image.png'),
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
                                        Text(
                                          'Forgot your password?',
                                          textAlign: TextAlign.center,
                                          style:
                                              context.titleTheme.headlineLarge,
                                        ),
                                        const SizedBox(height: 33),
                                        Text(
                                          'Let us know your email address and we will email you a password reset link that will allow you to choose a new one.',
                                          textAlign: TextAlign.center,
                                          style: context.textTheme.labelMedium,
                                        ),
                                        const SizedBox(height: 38),
                                        InputField.email(
                                          label: 'Enter your email',
                                          controller: emailController,
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.maxFinite,
                                          child: ElevatedButton(
                                            onPressed: () => {
                                              context
                                                  .read<AuthCubit>()
                                                  .resetPassword(
                                                      emailController.text)
                                            },
                                            child: Text('Reset Password'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                          ])),
                ],
            );
          } else {
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
                            image: ImageAsset('reset_pass_image.png'),
                            fit: BoxFit.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Forgot your password?',
                        textAlign: TextAlign.center,
                        style: context.titleTheme.headlineLarge,
                      ),
                      const SizedBox(height: 33),
                      Text(
                        'Let us know your email address and we will email you a password reset link that will allow you to choose a new one.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 38),
                      InputField.email(
                        label: 'Enter your email',
                        controller: emailController,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => {
                          context
                              .read<AuthCubit>()
                              .resetPassword(emailController.text)
                        },
                        child: const Text('Reset Password'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          ;

          return Scaffold(
            body: LoadingOverlay(
                loading: state.loading ?? false,
                child: Container(
                  color: Colors.white,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: body,
                    ),
                  ),
                )),
          );
        });
  }
}
