import 'package:cinteraction_vc/core/app/style.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/conference/conference_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../layers/presentation/cubit/app/app_cubit.dart';
import '../../layers/presentation/cubit/profile/profile_cubit.dart';
import '../deep_link_router.dart';
import '../navigation/router.dart';
import 'injector.dart';

class CinteractionFlutterApp extends StatelessWidget {
  const CinteractionFlutterApp({super.key});


  @override
  Widget build(BuildContext context) {
     return  BlocProvider<AppCubit>(
        create: (_) => AppCubit(),
        child: MaterialApp.router(
          title: 'Cinteraction',
          theme: lightTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      );
  }
}
