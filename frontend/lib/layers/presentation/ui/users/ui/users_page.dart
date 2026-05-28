import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_state.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/users/ui/widget/user_list_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/ui/widget/loading_overlay.dart';
import '../../../../domain/entities/user.dart';
import '../../../cubit/users/users_cubit.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) => previous.user != current.user,
      listener: (context, state) {
        if (state.user?.companyId == null) {
          print('REDIRECT: companyId is null!');
          context.go(AppRoute.createCompany.path);
        }
      },
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return LoadingOverlay(
            loading: state is UsersIsLoading,
            child: const SizedBox(
              height: double.maxFinite,
              width: double.maxFinite,
              child: Column(
                children: [
                  UserListLayout(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
