import 'package:flutter/material.dart';

const desktopWidthBreakpoint = 768.0;
const mobileWidthBreakpoint = 600.0;

class ResponsiveLayout extends StatelessWidget {

  final Widget body;

  const ResponsiveLayout({super.key, required this.body});

  // const ConstrainedWidth.desktop({
  //   required this.child,
  //   super.key,
  // }) : maxWidth = desktopWidthBreakpoint;
  //
  // const ConstrainedWidth.mobile({
  //   required this.child,
  //   super.key,
  // }) : maxWidth = mobileWidthBreakpoint;

  // final double maxWidth;


  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(
      builder: (context, constraint) {
        return Center(
          child: Form(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraint.maxWidth < mobileWidthBreakpoint? mobileWidthBreakpoint: constraint.maxWidth, minHeight: constraint.maxHeight),
                  child: IntrinsicHeight(
                      child: body
              ),
            ),
          ),

        ),);
      },
    )
    );
  }
}
