import 'dart:math';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:cinteraction_vc/core/util/menu_items.dart';
import 'package:cinteraction_vc/layers/domain/usecases/call/call_use_cases.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/chat_usecases.dart';
import 'package:cinteraction_vc/layers/domain/usecases/conference/conference_usecases.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/home/home_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/auth/reset_pass_enter_new.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/chat_room.dart';
import 'package:cinteraction_vc/layers/presentation/ui/company/create_company_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../layers/data/repos/auth_repo_impl.dart';
import '../../layers/data/source/local/local_storage.dart';
import '../../layers/domain/repos/auth_repo.dart';
import '../../layers/domain/usecases/auth/auth_usecases.dart';
import '../../layers/presentation/cubit/auth/auth_cubit.dart';
import '../../layers/presentation/cubit/conference/conference_cubit.dart';
import '../../layers/presentation/ui/auth/auth_page.dart';
import '../../layers/presentation/ui/auth/forgot_pass_page.dart';
import '../../layers/presentation/ui/auth/reset_pass_send_email.dart';
import '../../layers/presentation/ui/auth/splash_page.dart';
import '../../layers/presentation/ui/conference/video_room.dart';
import '../../layers/presentation/ui/echotest/EchoTestWidget.dart';
import '../../layers/presentation/ui/landing/ui/page/home_page.dart';
import '../util/secure_local_storage.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoute.splash.path,
  routes: [
    // Splash
    GoRoute(
      path: AppRoute.splash.path,
      builder: (context, state) => const SplashPage(),
      // builder: (context, state) {
      //   return BlocProvider(
      //     create: (context) => StaggeredCubit(),
      //     child: const StaggeredAspectGrid(),
      //   );
      // }  ,
    ),
    // Auth
    GoRoute(
      path: AppRoute.auth.path,
      builder: (context, state) {
        print("router: ${AppRoute.auth.path}");
        return BlocProvider(
          create: (context) => AuthCubit(
            authUseCases: getIt.get<AuthUseCases>(),
          ),
          child: AuthPage(),
        );
      },
      redirect: (context, state) {
        print('🔁${state.uri.toString()}');
        var user = context.getCurrentUser;
        if (user != null) {
          print("router: ${AppRoute.home.path}");
          return AppRoute.home.path;
        }
        return null;
      },
    ),
    // Forgot Password
    // GoRoute(
    //   path: AppRoute.forgotPassword.path,
    //   builder: (context, state) => const ForgotPasswordPage(),
    // ),
    //
    GoRoute(
      path: AppRoute.forgotPassword.path,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => AuthCubit(
            authUseCases: getIt.get<AuthUseCases>(),
          ),
          child: const ForgotPasswordPage(),
        );
      },
    ),

    //New password
    GoRoute(
      path: AppRoute.enterNewPassword.path,
      builder: (context, state) {
        // final hash = state.pathParameters['hash'];
        final Map<String, String> queryParameters = state.uri.queryParameters;
        // print("email: ${queryParameters["email"]}");
        final email = queryParameters["email"];
        final token = queryParameters["token"];

        return BlocProvider(
          create: (context) => AuthCubit(
            authUseCases: getIt.get<AuthUseCases>(),
          ),
          child: EnterNewPassword(token: token ?? "", email: email ?? ""),
        );
      },
    ),

    // Forgot Password Success
    GoRoute(
      path: AppRoute.forgotPasswordSuccess.path,
      builder: (context, state) => const ResetPassEmailPage(),
    ),
    // Home
    GoRoute(
      path: AppRoute.home.path,
      builder: (context, state) {
        print("router: ${AppRoute.home.path}");
        // return BlocProvider(
        //   create: (context) => getIt.get<ChatCubit>(),
        //   child: const HomePage(),
        // );

        return MultiBlocProvider(
          providers: [
            BlocProvider<ChatCubit>.value(
              value: getIt.get<ChatCubit>(),
            ),
            BlocProvider<AppCubit>.value(
              value: getIt.get<AppCubit>(),
            )
          ],
          child: const HomePage(),
        );
      },
      redirect: (context, state) {
        print('🔁 Router redirect triggered for path: ${state.uri.toString()}');
        var user = context.getCurrentUser;
        if (user == null) {
          print("router: ${AppRoute.auth.path}");
          return AppRoute.auth.path;
        }

        if (user.companyId == null) {
          return AppRoute.createCompany.path;
        }
        var roomId = getIt.get<LocalStorage>().getRoomId();
        if (roomId != null) {
          getIt.get<LocalStorage>().clearRoomId();
          return AppRoute.meeting.path.replaceAll(':roomId', roomId);
        }
        return null;
      },
    ),

    // Create company
    GoRoute(
      path: AppRoute.createCompany.path,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<CompanyCubit>(), // ako si ga registrovao u getIt
          child: const CreateCompanyPage(),
        );
      },
    ),

    // Meeting
    GoRoute(
      path: AppRoute.meeting.path,
      name: 'meeting',
      builder: (context, state) {
        // final roomId = state.extra ?? '1234';
        final display = state.extra ?? 'displayName';
        final roomId = state.pathParameters['roomId'] ?? Random().nextInt(999999);

        return MultiBlocProvider(providers: [
          BlocProvider<ConferenceCubit>(
              create: (context) => ConferenceCubit(
                  conferenceUseCases: getIt.get<ConferenceUseCases>(),
                  roomId: int.parse(roomId.toString()),
                  displayName: display.toString())),
          BlocProvider<ChatCubit>(
            create: (context) => ChatCubit(
                callUseCases: getIt.get<CallUseCases>(),
                chatUseCases: getIt.get<ChatUseCases>(),
                isInCallChat: true),
          ),
        ], child: const VideoRoomPage());
      },
      redirect: (context, state) async {
        print('🔁 Router redirect triggered for path: ${state.uri.toString()}');

        // if (kIsWeb) {
        //   var roomId = state.pathParameters['roomId'];
        //   startMeetOnDesktop(int.parse(roomId.toString()));
        //   return AppRoute.auth.path;
        // }

        var user = context.getCurrentUser;

        if (user == null) {
          var roomId = state.pathParameters['roomId'];
          final qp = Map<String, String>.from(state.uri.queryParameters);
          final username = qp['user'];
          final password = qp['pass'];

          if(username != null && password != null)
            {
              var response = await getIt.get<AuthRepo>().signInWithEmailAndPassword(email: username, password: password);
              if (response.error == null) {

                qp.remove('user');
                qp.remove('pass');

                if(roomId != null)
                  {
                    return AppRoute.meeting.path.replaceAll(':roomId', roomId);
                  }
                // return AppRoute.meeting.path;
              }
            }

          if (roomId != null) {
            getIt.get<LocalStorage>().saveRoomId(roomId: roomId);
          }
          return AppRoute.auth.path;
        }

        return null;
      },
    ),

    // Users
    GoRoute(
      path: AppRoute.users.path,
      builder: (context, state) {
        final id = state.extra ?? '';
        return UsersScreen(id: id as String).builder(context);
      },
    ),
    // Groups
    GoRoute(
      path: AppRoute.groups.path,
      builder: (context, state) {
        return groups.builder(context);
      },
    ),
    // Roles
    GoRoute(
      path: AppRoute.roles.path,
      builder: (context, state) {
        return roles.builder(context);
      },
    ),

    GoRoute(
      path: AppRoute.echo.path,
      builder: (context, state) {
        return const EchoTestWidget();
      },
    ),

    GoRoute(
      path: AppRoute.chat.path,
      builder: (context, state) {
        // final roomId = state.extra ?? '1234';
        final display = state.extra ?? 'displayName';
        final roomId =
            state.pathParameters['roomId'] ?? Random().nextInt(999999);
        // final display =  state.pathParameters['displayName'] ?? 'displayName';

        // final roomId = state.pathParameters['roomId'];
        return MultiBlocProvider(
          providers: [
            BlocProvider<HomeCubit>.value(
              value: getIt<HomeCubit>(),
            ),
            BlocProvider<ChatCubit>.value(
              value: getIt.get<ChatCubit>(),
            ),
          ],
          child: const ChatRoomPage(),
        );
      },
    ),
  ],
);
