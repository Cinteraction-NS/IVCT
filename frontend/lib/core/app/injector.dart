import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:cinteraction_vc/core/navigation/router.dart';
import 'package:cinteraction_vc/core/util/secure_local_storage.dart';
import 'package:cinteraction_vc/layers/data/repos/ai_module_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/repos/chat_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/repos/company_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/repos/conference_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/repos/dashboard_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/repos/meetings_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/source/network/api_impl.dart';
import 'package:cinteraction_vc/layers/domain/repos/ai_repo.dart';
import 'package:cinteraction_vc/layers/domain/repos/call_repo.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';
import 'package:cinteraction_vc/layers/domain/repos/company_repo.dart';
import 'package:cinteraction_vc/layers/domain/repos/conference_repo.dart';
import 'package:cinteraction_vc/layers/domain/repos/dashboard_repo.dart';
import 'package:cinteraction_vc/layers/domain/repos/home_repo.dart';
import 'package:cinteraction_vc/layers/domain/usecases/ai/ai_use_cases.dart';
import 'package:cinteraction_vc/layers/domain/usecases/call/call_use_cases.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/chat_usecases.dart';
import 'package:cinteraction_vc/layers/domain/usecases/company/company_use_cases.dart';
import 'package:cinteraction_vc/layers/domain/usecases/dashboard/dashboard_usecases.dart';
import 'package:cinteraction_vc/layers/domain/usecases/home/home_use_cases.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/ai/ai_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_cubit.dart';
import 'package:cinteraction_vc/main.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import '../../layers/data/repos/auth_repo_impl.dart';
import '../../layers/data/repos/call_repo_impl.dart';
import '../../layers/data/repos/home_repo_impl.dart';
import '../../layers/data/source/local/local_storage.dart';
import '../../layers/domain/repos/auth_repo.dart';
import '../../layers/domain/repos/meetings_repo.dart';
import '../../layers/domain/source/api.dart';
import '../../layers/domain/usecases/auth/auth_usecases.dart';
import '../../layers/domain/usecases/conference/conference_usecases.dart';
import '../../layers/domain/usecases/meeting/meeting_use_cases.dart';
import '../../layers/presentation/cubit/dashboard/dashboard_cubit.dart';
import '../../layers/presentation/cubit/home/home_cubit.dart';
import '../../layers/presentation/cubit/meetings/meetings_cubit.dart';
import '../../layers/presentation/cubit/users/users_cubit.dart';
import '../../layers/presentation/ui/groups/provider/groups_provider.dart';
import '../../layers/presentation/ui/groups/repository/groups_repository.dart';
import '../../layers/presentation/ui/profile/provider/user_mock_provider.dart';
import '../../layers/presentation/ui/profile/repository/profile_repository.dart';
import '../../layers/presentation/ui/roles/provider/roles_provider.dart';
import '../../layers/presentation/ui/roles/repository/roles_repository.dart';
import '../../layers/presentation/ui/users/provider/users_provider.dart';
import '../../layers/presentation/ui/users/repository/users_repository.dart';
import '../io/network/urls.dart';
import '../janus/janus_client.dart';
import '../util/conf.dart';

GetIt getIt = GetIt.instance;

void resetAndReinitialize() async {
  await getIt.reset(); // Clears all registered instances
  initializeGetIt(); // Re-register instances
}

Future<void> initializeGetIt() async {
  getIt.registerFactoryAsync<Dio>(() async {
    final accessToken = await getAccessToken();
    // print('ACCESS: $accessToken');
    final dio = Dio(BaseOptions(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': accessToken
      },
      validateStatus: (statusCode) {
        if (statusCode == null) {
          return false;
        }

        return statusCode >= 200 && statusCode < 300;
      },
    ));
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (
          DioException e,
          handler,
        ) async {
          if (e.response?.statusCode == 401) {
            print("Token expired. Logging out...");
            await getIt.get<LocalStorage>().clearUser();
            // getIt.get<ChatCubit>().chatUseCases.leaveRoom();
            resetAndReinitialize();
            router.replace(AppRoute.auth.path);
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  });

  // getIt.registerFactory<Dio>(() => Dio(
  //     BaseOptions(
  //   headers: {
  //     'Accept': 'application/json',
  //     'Content-Type': 'application/json',
  //     'Authorization' :  getAccessToken()
  //   },
  //   validateStatus: (statusCode) {
  //     if (statusCode == null) {
  //       return false;
  //     }
  //     if (statusCode == 422) {
  //       // your http status code
  //       return true;
  //     } else {
  //       return statusCode >= 200 && statusCode < 300;
  //     }
  //   },
  // )));

  getIt.registerSingleton<Api>(ApiImpl());

  // getIt.registerSingleton<GoRouter>(router);

  getIt.registerFactory<LocalStorage>(
    () => LocalStorageImpl(sharedPreferences: sharedPref),
  );

  getIt.registerFactory<AuthRepo>(
    () => AuthRepoImpl(api: getIt()),
  );
  getIt.registerFactory<ConferenceRepo>(() => ConferenceRepoImpl(api: getIt()));
  getIt.registerFactory<ChatRepo>(() => ChatRepoImpl(api: getIt()));

  getIt.registerFactory<CallRepo>(() => CallRepoImpl(api: getIt()));

  getIt.registerFactory<MeetingRepo>(() => MeetingRepoImpl(api: getIt()));
  getIt.registerFactory<HomeRepo>(() => HomeRepoImpl(api: getIt()));
  getIt.registerFactory<DashboardRepo>(() => DashboardRepoImpl(api: getIt()));

  getIt.registerFactory<UsersProvider>(() => UsersProvider());
  getIt.registerFactory<GroupsProvider>(() => GroupsProvider());
  getIt.registerFactory<RolesProvider>(() => RolesProvider());
  getIt.registerFactory<GroupsRepository>(
      () => GroupsRepository(groupsProvider: getIt()));
  getIt.registerFactory<UsersRepository>(
      () => UsersRepository(usersProvider: getIt()));

  getIt.registerFactory<RolesRepository>(
      () => RolesRepository(rolesProvider: getIt()));
  getIt.registerSingleton<UsersCubit>(
      UsersCubit(groupRepository: getIt(), usersRepository: getIt()));

  getIt.registerFactory(() => AuthUseCases());
  getIt.registerFactory(() => ConferenceUseCases(repo: getIt()));
  getIt.registerFactory(() => MeetingUseCases(repo: getIt()));
  getIt.registerFactory(() => HomeUseCases(repo: getIt()));
  getIt.registerFactory(() => DashboardUseCases());
  getIt.registerFactory(() => ChatUseCases(repo: getIt()));
  getIt.registerFactory(() => CallUseCases(repo: getIt()));

  getIt.registerSingleton<ProfileProvider>(ProfileProvider());
  // getIt.registerFactory<UsersProvider>(() => UsersProvider());

  // getIt.registerFactory<UsersRepository>(() => UsersRepository(usersProvider: getIt()));
  getIt.registerSingleton<ProfileRepository>(
      ProfileRepository(profileProvider: getIt()));

  // getIt.registerSingleton<ProfileCubit>(ProfileCubit(userRepository: getIt()));
  getIt.registerFactory<HomeCubit>(() => HomeCubit(homeUseCases: getIt()));
  getIt.registerFactory<MeetingCubit>(
      () => MeetingCubit(meetingUseCases: getIt()));
  getIt.registerFactory<DashboardCubit>(
      () => DashboardCubit(dashboardUseCases: getIt()));

  getIt.registerLazySingleton<ChatCubit>(() => ChatCubit(
      chatUseCases: getIt(), callUseCases: getIt(), isInCallChat: false));

  getIt
      .registerFactory<JanusTransport>(() => WebSocketJanusTransport(url: url));
  getIt.registerFactory<JanusClient>(() => JanusClient(
      transport: getIt(),
      withCredentials: true,
      apiSecret: apiSecret,
      isUnifiedPlan: true,
      iceServers: iceServers,
      loggerLevel: Level.FINE));

  getIt.registerFactoryAsync<JanusSession>(() async {
    return await getIt.get<JanusClient>().createSession();
  });

  getIt.registerLazySingleton<AppCubit>(() => AppCubit());

  getIt.registerFactory<CompanyRepo>(() => CompanyRepoImpl(api: getIt()));
  getIt.registerFactory(() => CompanyUseCases(companyRepos: getIt()));
  getIt.registerFactory(() => CompanyCubit(
        companyUseCases: getIt(),
        appCubit: getIt<AppCubit>(),
      ));

  getIt.registerFactory<AiRepo>(() => AiModuleRepoImpl(api: getIt()));
  getIt.registerFactory(() => AiUseCases(aiRepos: getIt()));
  getIt.registerLazySingleton<AiCubit>(() => AiCubit(
        aiUseCases: getIt(),
        appCubit: getIt<AppCubit>(),
      ));

  Map<String, dynamic>? getHeader() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': getAccessToken()
    };
    return null;
  }
}
