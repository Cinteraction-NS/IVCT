import 'package:flutter/material.dart';

import '../../../assets/colors/Colors.dart';

class ContentLayoutWeb extends StatelessWidget{

  final Widget child;

  const ContentLayoutWeb({super.key, required this.child});

  @override
  Widget build(BuildContext context) {


    return Expanded(
        child: Container(
          color: ColorConstants.kGrey100,
          child: Stack(
              children: [
                Positioned(
                    right: 20,
                    left: 20,
                    top: 20,
                    bottom: 20,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: child,
                        )

                    )

                )
              ]

          ),
        ));
  }

}
