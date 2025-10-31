// core/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ Added

// Core
import './network/network_info.dart';
import './network/api_client.dart';

// Auth
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/use_cases/login_usecase.dart';
import '../../features/auth/domain/use_cases/signup_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// Teams
import '../../features/teams/data/data_sources/remote/team_remote_data_source.dart';
import '../../features/teams/data/data_sources/local/team_local_data_source.dart';
import '../../features/teams/data/repositories/team_repository_impl.dart';
import '../../features/teams/domain/repositories/team_repository.dart';
import '../../features/teams/domain/use_cases/get_user_teams_usecase.dart';
import '../../features/teams/domain/use_cases/search_teams_usecase.dart';
import '../../features/teams/domain/use_cases/create_team_usecase.dart';
import '../../features/teams/domain/use_cases/get_all_teams_usecase.dart';
import '../../features/teams/domain/use_cases/join_team_usecase.dart';
import '../../features/teams/presentation/blocs/teams/teams_cubit.dart';
import '../../features/teams/presentation/blocs/create_team/create_team_cubit.dart';
import '../../features/teams/presentation/blocs/browse_teams/browse_teams_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // ✅ Load environment variables (make sure dotenv is initialized in main.dart)
  await dotenv.load(fileName: ".env");

  // ✅ Read API URL from .env or fallback to ngrok URL
  final baseUrl =
      dotenv.env['API_URL'] ??
      'https://fattiest-ebony-supplely.ngrok-free.dev/api/v1';

  // Core dependencies
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  getIt.registerLazySingleton<ApiClient>(() => ApiClient(baseUrl: baseUrl));

  // Auth dependencies
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(secureStorage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: getIt<LoginUseCase>(),
      signUpUseCase: getIt<SignUpUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Data Sources
  getIt.registerLazySingleton<TeamRemoteDataSource>(
    () => TeamRemoteDataSourceImpl(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<TeamLocalDataSource>(
    () => TeamLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(
      remoteDataSource: getIt<TeamRemoteDataSource>(),
      localDataSource: getIt<TeamLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetUserTeamsUseCase>(
    () => GetUserTeamsUseCase(getIt<TeamRepository>()),
  );

  getIt.registerLazySingleton<SearchTeamsUseCase>(
    () => SearchTeamsUseCase(getIt<TeamRepository>()),
  );

  getIt.registerLazySingleton<CreateTeamUseCase>(
    () => CreateTeamUseCase(getIt<TeamRepository>()),
  );

  getIt.registerLazySingleton<GetAllTeamsUseCase>(
    () => GetAllTeamsUseCase(getIt<TeamRepository>()),
  );

  getIt.registerLazySingleton<JoinTeamUseCase>(
    () => JoinTeamUseCase(getIt<TeamRepository>()),
  );

  // Blocs/Cubits
  getIt.registerFactory<TeamsCubit>(
    () => TeamsCubit(
      getUserTeamsUseCase: getIt<GetUserTeamsUseCase>(),
      searchTeamsUseCase: getIt<SearchTeamsUseCase>(),
    ),
  );

  getIt.registerFactory<CreateTeamCubit>(
    () => CreateTeamCubit(createTeamUseCase: getIt<CreateTeamUseCase>()),
  );

  getIt.registerFactory<BrowseTeamsCubit>(
    () => BrowseTeamsCubit(
      getAllTeams: getIt<GetAllTeamsUseCase>(),
      getUserTeams: getIt<GetUserTeamsUseCase>(),
      joinTeamUseCase: getIt<JoinTeamUseCase>(),
    ),
  );
}
