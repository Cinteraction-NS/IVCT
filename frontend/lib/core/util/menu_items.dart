import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/ai/ai_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/ai/ui/ai_page.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/chat_room.dart';
import 'package:cinteraction_vc/layers/presentation/ui/dashboard/ui/dashboard_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../layers/presentation/cubit/chat/chat_cubit.dart';
import '../../layers/presentation/cubit/groups/groups_cubit.dart';
import '../../layers/presentation/cubit/home/home_cubit.dart';
import '../../layers/presentation/cubit/meetings/meetings_cubit.dart';
import '../../layers/presentation/cubit/roles/roles_cubit.dart';
import '../../layers/presentation/cubit/users/users_cubit.dart';
import '../../layers/presentation/ui/charts/ui/charts_screen.dart';
import '../../layers/presentation/ui/groups/repository/groups_repository.dart';
import '../../layers/presentation/ui/groups/ui/groups_page.dart';
import '../../layers/presentation/ui/home/ui/home_tab.dart';
import '../../layers/presentation/ui/meetings/ui/meetings_page.dart';
import '../../layers/presentation/ui/profile/ui/profile_tab.dart';
import '../../layers/presentation/ui/roles/repository/roles_repository.dart';
import '../../layers/presentation/ui/roles/ui/roles_page.dart';
import '../../layers/presentation/ui/users/repository/users_repository.dart';
import '../../layers/presentation/ui/users/ui/users_page.dart';
import '../app/injector.dart';
import '../navigation/route.dart';

final mobileBottomMenu = <MenuItem>[
  buildChatMenuItem(),
  // dashboard,
  meetings,
  users,
  aiModules,
  // insights,
  profile
];
final mobileProfileMenu = <MenuItem>[
  // users,
  // groups,
  // notifications,
  // tags,
  // roles,
  // permissions,
  // settings
];
final desktopMenu = <MenuItem>[
  // home,
  buildChatMenuItem(),
  // dashboard,
  meetings,
  users,
  aiModules,
  profile,

  // insights,

  // groups,
  // tags,
  // roles,
  // permissions,
  // settings
];

class MenuItem {
  MenuItem({
    required this.label,
    required this.assetName,
    required this.body,
    this.route,
  });

  final String label;
  final String assetName;
  final Widget body;

  late WidgetBuilder builder = (context) => DefaultTextStyle(
      style: context.textTheme.bodySmall!.copyWith(), child: body);

  final AppRoute? route;
}

class UsersScreen extends MenuItem {
  UsersScreen({required this.id})
      : super(
            label: 'Users',
            assetName: 'community',
            body: BlocProvider(
              create: (context) => UsersCubit(
                usersRepository: getIt.get<UsersRepository>(),
                groupRepository: getIt.get<GroupsRepository>(),
              ),
              child: UsersPage(groupId: id),
            ));

  final String id;
}

final home = MenuItem(
    route: AppRoute.home,
    label: 'Home',
    assetName: 'menu_home',
    body: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt.get<HomeCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt.get<AppCubit>(),
        ),
      ],
      child: const HomeTab(),
    ));
final dashboard = MenuItem(
    route: null,
    label: 'Dashboard',
    assetName: 'menu_dashboard',
    body: BlocProvider(
      create: (context) => getIt.get<DashboardCubit>(),
      child: const DashboardScreen(),
    ));
final meetings = MenuItem(
    route: null,
    label: 'Meetings',
    assetName: 'menu_meetings',
    body: BlocProvider(
      create: (context) => getIt.get<MeetingCubit>(),
      child: const MeetingsPage(),
    ));
// final insights = MenuItem(
//   route: null,
//   label: 'Insights',
//   assetName: 'menu_insights',
//   body: const InsightsScreen(),
// );

final aiModules = MenuItem(
  route: null,
  label: 'AI',
  assetName: 'menu_ai',
  body: BlocProvider.value(
    value: getIt<AiCubit>(),
    child: const AiModulesPage(),
  ),
);

final profile = MenuItem(
  route: null,
  label: 'Profile',
  assetName: 'menu_profile',
  body: const ProfileTab(),
);
final users = UsersScreen(id: '');
final groups = MenuItem(
  route: AppRoute.groups,
  label: 'Groups',
  assetName: 'menu_groups',
  body: BlocProvider(
    create: (context) => GroupsCubit(
      groupRepository: getIt.get<GroupsRepository>(),
    ),
    child: const GroupsPage(),
  ),
);
final tags = MenuItem(
  route: null,
  label: 'Tags',
  assetName: 'menu_tags',
  body: const Center(child: Text('Tags')),
);
final roles = MenuItem(
  route: AppRoute.roles,
  label: 'Roles',
  assetName: 'menu_roles',
  body: BlocProvider(
    create: (context) => RolesCubit(
      roleRepository: getIt.get<RolesRepository>(),
    ),
    child: const RolesPage(),
  ),
);
final permissions = MenuItem(
  route: null,
  label: 'Permissions',
  assetName: 'menu_permissions',
  body: const Center(child: Text('Permissions')),
);
final settings = MenuItem(
  route: null,
  label: 'Settings',
  assetName: 'menu_settings',
  body: const Center(child: Text('Settings')),
);
final notifications = MenuItem(
  route: null,
  label: 'Notifications',
  assetName: 'menu_notifications',
  body: const Center(child: Text('Notifications')),
);

MenuItem buildChatMenuItem() {
  return MenuItem(
    route: null,
    label: 'Chat',
    assetName: 'menu_chat',
    body: MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => getIt.get<HomeCubit>(),
        ),
      ],
      child: const ChatRoomPage(),
    ),
  );
}

final chat = MenuItem(
    route: null,
    label: 'Chat',
    assetName: 'menu_chat',
    body: MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => getIt.get<HomeCubit>(),
        ),
        BlocProvider<ChatCubit>.value(
          value: getIt.get<ChatCubit>(),
        ),
      ],
      child: const ChatRoomPage(),
    )

    // body:   ChatRoomPage(),
    );
