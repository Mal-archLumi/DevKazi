// core/injection_container.dart - Complete version with all fixes
import 'dart:async';
import 'package:frontend/features/chat/domain/use_cases/delete_messages_use_case.dart';
import 'package:frontend/features/teams/domain/use_cases/get_pending_requests_usecase.dart'; // Already imported
import 'package:frontend/features/teams/presentation/blocs/browse_teams/browse_teams_cubit.dart';
import 'package:frontend/features/teams/presentation/blocs/create_team/create_team_cubit.dart';
import 'package:frontend/features/teams/presentation/blocs/teams/teams_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
import '../../features/teams/domain/use_cases/search_browse_teams_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/get_team_by_id_usecase.dart';
import 'package:frontend/features/teams/presentation/blocs/team_details/team_details_cubit.dart';
import '../../features/teams/domain/use_cases/leave_team_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/get_team_join_requests_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/handle_join_request_usecase.dart';
import 'package:frontend/features/teams/presentation/cubits/join_requests_cubit.dart';

// Projects
import '../../features/projects/data/data_sources/project_remote_data_source.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/use_cases/get_projects_usecase.dart';
import '../../features/projects/domain/use_cases/create_project_usecase.dart';
import '../../features/projects/domain/use_cases/pin_link_usecase.dart';
import '../../features/projects/domain/use_cases/add_idea_usecase.dart';
import '../../features/projects/presentation/cubits/projects_cubit.dart';

// Chat
import '../../features/chat/data/data_sources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/use_cases/get_messages_use_case.dart';
import '../../features/chat/domain/use_cases/send_message_use_case.dart';
import '../../features/chat/presentation/cubits/chat_cubit.dart';

// User
import '../../features/user/data/data_sources/user_remote_data_source.dart';
import '../../features/user/data/data_sources/user_local_data_source.dart';
import '../../features/user/data/repositories/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';
import '../../features/user/domain/use_cases/get_current_user_use_case.dart';
import '../../features/user/domain/use_cases/update_profile_use_case.dart';
import '../../features/user/domain/use_cases/logout_use_case.dart';
import '../../features/user/presentation/cubits/user_cubit.dart';

// Notifications
import '../../features/notifications/data/data_sources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/use_cases/get_notifications_use_case.dart';
import '../../features/notifications/domain/use_cases/clear_notifications_use_case.dart';
import '../../features/notifications/presentation/cubits/notifications_cubit.dart';

// Events
import 'package:frontend/core/events/user_status_events.dart';

final getIt = GetIt.instance;

// Create a shared stream controller for user status events
final StreamController<UserStatusEvent> _userStatusController =
    StreamController<UserStatusEvent>.broadcast();

Future<void> initDependencies() async {
  await dotenv.load(fileName: ".env");

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

  // Team dependencies
  getIt.registerLazySingleton<TeamRemoteDataSource>(
    () => TeamRemoteDataSourceImpl(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<TeamLocalDataSource>(
    () => TeamLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(
      remoteDataSource: getIt<TeamRemoteDataSource>(),
      localDataSource: getIt<TeamLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GetUserTeamsUseCase>(
    () => GetUserTeamsUseCase(getIt<TeamRepository>()),
  );

  getIt.registerLazySingleton<SearchTeamsUseCase>(
    () => SearchTeamsUseCase(getIt<TeamRepository>()),
  );

  getIt.registerLazySingleton<SearchBrowseTeamsUseCase>(
    () => SearchBrowseTeamsUseCase(getIt<TeamRepository>()),
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

  // ADD THIS LINE - Register GetPendingRequestsUseCase
  getIt.registerLazySingleton<GetPendingRequestsUseCase>(
    () => GetPendingRequestsUseCase(repository: getIt<TeamRepository>()),
  );

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
      searchBrowseTeams: getIt<SearchBrowseTeamsUseCase>(),
      getPendingRequestsUseCase:
          getIt<GetPendingRequestsUseCase>(), // Now this will work
    ),
  );

  // Project dependencies
  getIt.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(
      remoteDataSource: getIt<ProjectRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GetProjectsUseCase>(
    () => GetProjectsUseCase(getIt<ProjectRepository>()),
  );

  getIt.registerLazySingleton<CreateProjectUseCase>(
    () => CreateProjectUseCase(getIt<ProjectRepository>()),
  );

  getIt.registerLazySingleton<PinLinkUseCase>(
    () => PinLinkUseCase(getIt<ProjectRepository>()),
  );

  getIt.registerLazySingleton<AddIdeaUseCase>(
    () => AddIdeaUseCase(getIt<ProjectRepository>()),
  );

  getIt.registerFactory<ProjectsCubit>(
    () => ProjectsCubit(getIt<ProjectRepository>()),
  );

  // Chat dependencies
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: getIt<ChatRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GetMessagesUseCase>(
    () => GetMessagesUseCase(getIt<ChatRepository>()),
  );

  // FIXED: SendMessageUseCase with correct constructor
  getIt.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(repository: getIt<ChatRepository>()),
  );

  // ADD THIS: DeleteMessagesUseCase registration
  getIt.registerLazySingleton<DeleteMessagesUseCase>(
    () => DeleteMessagesUseCase(repository: getIt<ChatRepository>()),
  );

  // UPDATED: ChatCubit with all required dependencies
  getIt.registerLazySingleton<ChatCubit>(
    () => ChatCubit(
      getMessagesUseCase: getIt<GetMessagesUseCase>(),
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      deleteMessagesUseCase: getIt<DeleteMessagesUseCase>(),
      repository: getIt<ChatRepository>(),
      userStatusController: _userStatusController,
    ),
  );

  // User dependencies
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(secureStorage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: getIt<UserRemoteDataSource>(),
      localDataSource: getIt<UserLocalDataSource>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<UserCubit>(
    () => UserCubit(
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => GetTeamByIdUseCase(repository: getIt<TeamRepository>()),
  );

  getIt.registerLazySingleton<LeaveTeamUseCase>(
    () => LeaveTeamUseCase(getIt<TeamRepository>()),
  );

  // UPDATED: TeamDetailsCubit with userStatusController
  getIt.registerFactory(
    () => TeamDetailsCubit(
      getTeamByIdUseCase: getIt<GetTeamByIdUseCase>(),
      leaveTeamUseCase: getIt<LeaveTeamUseCase>(),
      userStatusController: _userStatusController,
    ),
  );

  // Join Requests use cases
  getIt.registerLazySingleton(
    () => GetTeamJoinRequestsUseCase(getIt<TeamRepository>()),
  );
  getIt.registerLazySingleton(
    () => HandleJoinRequestUseCase(getIt<TeamRepository>()),
  );

  // Register JoinRequestsCubit - use factory so each screen gets fresh instance
  getIt.registerFactory<JoinRequestsCubit>(
    () => JoinRequestsCubit(teamRepository: getIt<TeamRepository>()),
  );

  // ============================================================================
  // NOTIFICATIONS DEPENDENCIES
  // ============================================================================

  // Notification Remote Data Source
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      baseUrl: baseUrl.replaceAll('/api/v1', ''),
      getToken: () async {
        final authRepo = getIt<AuthRepository>();
        return await authRepo.getAccessToken();
      },
    ),
  );

  // Notification Repository
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Notification Use Cases
  getIt.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerLazySingleton<ClearNotificationsUseCase>(
    () => ClearNotificationsUseCase(getIt<NotificationRepository>()),
  );

  // Notifications Cubit
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      getNotificationsUseCase: getIt<GetNotificationsUseCase>(),
      clearNotificationsUseCase: getIt<ClearNotificationsUseCase>(),
      repository: getIt<NotificationRepository>(),
    ),
  );
}

// Cleanup function to close the stream controller
Future<void> disposeDependencies() async {
  await _userStatusController.close();
}
