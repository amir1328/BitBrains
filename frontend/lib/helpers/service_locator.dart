import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/auth_remote_data_source.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/logic/bloc/auth_bloc.dart';
import '../features/materials/data/material_remote_data_source.dart';
import '../features/materials/data/material_repository.dart';
import '../features/materials/logic/bloc/material_bloc.dart';
import '../features/chat/data/chat_remote_data_source.dart';
import '../features/chat/data/chat_repository.dart';
import '../features/chat/logic/bloc/chat_bloc.dart';
import '../features/timetable/data/timetable_remote_data_source.dart';
import '../features/timetable/data/timetable_repository.dart';
import '../features/timetable/logic/bloc/timetable_bloc.dart';
import '../features/profile/data/profile_remote_data_source.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/logic/bloc/profile_bloc.dart';
import '../core/network/websocket_service.dart';
import '../features/group_chat/logic/bloc/group_chat_bloc.dart';
import '../features/achievements/data/achievement_remote_data_source.dart';
import '../features/achievements/data/achievement_repository.dart';
import '../features/achievements/logic/bloc/achievement_bloc.dart';
import '../features/alumni/data/alumni_remote_data_source.dart';
import '../features/alumni/data/alumni_repository.dart';
import '../features/alumni/logic/bloc/alumni_bloc.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Core / Network
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<WebSocketService>(() => WebSocketService());

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<MaterialRemoteDataSource>(
    () => MaterialRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<TimetableRemoteDataSource>(
    () => TimetableRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MaterialRepository>(
    () => MaterialRepository(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepository(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TimetableRepository>(
    () => TimetableRepository(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(remoteDataSource: sl()),
  );

  // BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl(), profileRepository: sl()),
  );
  sl.registerFactory<MaterialBloc>(() => MaterialBloc(repository: sl()));
  sl.registerFactory<ChatBloc>(() => ChatBloc(repository: sl()));
  sl.registerFactory<TimetableBloc>(() => TimetableBloc(repository: sl()));
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(repository: sl()));
  sl.registerFactory<GroupChatBloc>(
    () => GroupChatBloc(webSocketService: sl(), apiClient: sl()),
  );

  // Achievements
  sl.registerLazySingleton<AchievementRemoteDataSource>(
    () => AchievementRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<AchievementRepository>(
    () => AchievementRepository(remoteDataSource: sl()),
  );
  sl.registerFactory<AchievementBloc>(() => AchievementBloc(repository: sl()));

  // Alumni
  sl.registerLazySingleton<AlumniRemoteDataSource>(
    () => AlumniRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<AlumniRepository>(
    () => AlumniRepository(remoteDataSource: sl()),
  );
  sl.registerFactory<AlumniBloc>(() => AlumniBloc(repository: sl()));
}
