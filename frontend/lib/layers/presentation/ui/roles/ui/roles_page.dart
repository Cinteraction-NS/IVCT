import 'package:cinteraction_vc/layers/presentation/ui/roles/ui/widget/role_list_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/ui/widget/loading_overlay.dart';
import '../../../cubit/roles/roles_cubit.dart';
import '../model/role.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<RolesPage> {
  late List<Role>? roleList = [];


  @override
  void initState(){
    super.initState();
    context.read<RolesCubit>().loadRoles();

  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RolesCubit, RoleState>(
        builder: (context, state) {
          final Widget body;

          body = Material(
            child: Column(
              children: [
                RolesListLayout(roles: roleList!),
              ],
            ),
          );

          // return const Text('No Users');

          return LoadingOverlay(
              loading: state is RolesIsLoading,
              child: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                  child: body,
              ));
        },
        listener: _onUsersState);
  }

  void _onUsersState(BuildContext context, RoleState state) {
    if (state is RolesLoaded) {
      setState(() {
        roleList = state.roles;
      });
    }
  }
}
