import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';

import '../../../../../core/ui/images/image.dart';
import '../../../../../core/ui/widget/responsive.dart';
import '../../../../core/navigation/route.dart';
import '../../../../core/ui/widget/loading_overlay.dart';

class ResetPassEmailPage extends StatelessWidget{
  const ResetPassEmailPage({super.key});

  @override
  Widget build(BuildContext context) {


    final Widget body;

    if(context.isWide)
      {
        body = Material(
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
                            image: ImageAsset('reset_pass_check_mail.png'),
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


                                   SizedBox(
                                     width: double.maxFinite,
                                     child:
                                     ElevatedButton(
                                       onPressed: ()=>{
                                         AppRoute.auth.push(context)
                                       },
                                       child: const Text('Ok'),
                                     ),
                                   ),

                                 ],
                                ),
                              ),
                            ))
                      ])),
            ],
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
  }

  // void _submit(BuildContext context) {
  // }
}