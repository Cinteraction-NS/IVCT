import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:flutter/material.dart';

class MobileToolbarScreen extends StatelessWidget {
  final Widget body;
  final String title;

  const MobileToolbarScreen(
      {super.key, required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: imageSVGAsset('back_button') as Widget,
          ),
          title: Text(title),
          titleTextStyle:
              context.textTheme.bodySmall?.copyWith(color: Colors.white)),
      body: SafeArea(child: body),
    );
  }
}
