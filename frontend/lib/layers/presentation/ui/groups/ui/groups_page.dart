
import 'package:cinteraction_vc/layers/presentation/ui/groups/ui/widget/groups_list_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/ui/widget/loading_overlay.dart';
import '../../../cubit/groups/groups_cubit.dart';
import '../model/group.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  GroupsPageState createState() => GroupsPageState();
}

class GroupsPageState extends State<GroupsPage> {
  late List<Group> groupList = [];

  @override
  void initState() {
    super.initState();
    final groupCubit = context.read<GroupsCubit>();
    groupCubit.loadGroups();
  }


  @override
  Widget build(BuildContext context) {

    return BlocConsumer<GroupsCubit, GroupsState>(
        builder: (context, state) {
          final Widget body;
          body = Material(
            child: Column(
              children: [
                if (state is GroupDetails)
                  Text(state.group.name)
                else
                  GroupListLayout(groups: groupList),
              ],
            ),
          );

          if (state is GroupDetails) {
            return Center(child: Text(state.group.name));
          }

          return LoadingOverlay(
              loading: state is GroupsIsLoading,
              child: SizedBox(
                height: double.maxFinite,
                width: double.maxFinite,
                child: body,
              ));
        },
        listener: _onUsersState);
  }

  void _onUsersState(BuildContext context, GroupsState state) {
    if (state is GroupsLoaded) {
      setState(() {
        groupList = state.groups;
      });
    }
  }
}
