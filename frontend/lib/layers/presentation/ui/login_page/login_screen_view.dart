import 'package:cinteraction_vc/core/ui/widget/ButtonRounded.dart';
import 'package:cinteraction_vc/core/ui/widget/EditText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/ui/images/image.dart';


class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 25, bottom: 12),
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 20,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          imageSVGAsset('original_long_logo') as Widget,
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 230,
                            height: 239,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'lib/assets/images/login_image.png'),
                                fit: BoxFit.none,
                              ),
                            ),
                          ),
                          const Text(
                            'Log in',
                            style: TextStyle(
                              color: Color(0xFF403736),
                              fontSize: 40,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      runSpacing: 20,
                      children: [
                        EditText(
                          hintText: 'Enter your email',
                        ),
                        EditText(
                            hintText: 'Enter your password', obscure: true),
                        Row(
                          children: [
                            Expanded(
                              child: ListTileTheme(
                                horizontalTitleGap: 0.0,
                                child: CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text('Remember me'),
                                  value: timeDilation != 1.0,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      timeDilation = value! ? 3.0 : 1.0;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Text('Forgot password'),
                          ],
                        ),
                      ],
                    ),
                    const ButtonRounded('Log in'),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: const Text(
                            'Or login with',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF4F4F4F),
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Container(
                          padding: const EdgeInsets.all(12),
                          width: 62.30,
                          height: 52.21,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 1, color: Color(0xFFBDBDBD)),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                            child: InkWell(
                                onTap: () => {

                                }, // needed
                                child: Image.asset(
                                  "lib/assets/images/google_log.png",
                                  fit: BoxFit.scaleDown,
                                )

                            )
                        ),


                        const SizedBox(width: 34),
                        Container(
                            padding: const EdgeInsets.all(12),
                            width: 62.30,
                            height: 52.21,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Color(0xFFBDBDBD)),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            child: InkWell(
                                onTap: () => {

                                }, // needed
                                child: Image.asset(
                                  "lib/assets/images/fb_logo.png",
                                  fit: BoxFit.scaleDown,
                                )

                            )
                        ),

                      ],
                    ),

                    const SizedBox(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Don’t have an account?',
                              style: TextStyle(
                                color: Color(0xFF828282),
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: ' ',
                              style: TextStyle(
                                color: Color(0xFF4F4F4F),
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: Color(0xFFF1471C),
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    // EditText(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
