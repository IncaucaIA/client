import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../features/filters/domain/filter_repository.dart';
import '../features/filters/data/filter_repository_impl.dart';
import '../features/filters/detail/bloc/filter_detail_bloc.dart';
import '../features/filters/list/bloc/filter_list_bloc.dart';
import '../features/filters/domain/websocket_datasource.dart';
import '../features/filters/data/azure_websocket_datasource_impl.dart';
import '../features/filters/data/local_websocket_datasource_impl.dart';
import 'config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/domain/auth_datasource.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/data/firebase_auth_datasource_impl.dart';
import '../features/auth/data/local_auth_datasource_impl.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/filters/notifications/bloc/notifications_bloc.dart';
import '../features/auth/application/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // External dependencies
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<Uuid>(() => const Uuid());
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Data sources
  if (AppConfig.isCloud) {
    getIt.registerLazySingleton<WebSocketDatasource>(
      () => AzureWebSocketDatasourceImpl(httpClient: getIt<http.Client>()),
    );
  } else {
    getIt.registerLazySingleton<WebSocketDatasource>(
      () => LocalWebSocketDatasourceImpl(httpClient: getIt<http.Client>()),
    );
  }

  // Auth Data sources
  if (AppConfig.isCloud) {
    getIt.registerLazySingleton<AuthDatasource>(
      () => FirebaseAuthDatasourceImpl(getIt<FirebaseAuth>()),
    );
  } else {
    getIt.registerLazySingleton<AuthDatasource>(
      () => LocalAuthDatasourceImpl(httpClient: getIt<http.Client>()),
    );
  }

  // Repository
  getIt.registerLazySingleton<FilterRepository>(
    () => FilterRepositoryImpl(
      webSocketDataSource: getIt<WebSocketDatasource>(),
      httpClient: getIt<http.Client>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthDatasource>()),
  );

  // BLoC - registered as factory to create new instances when needed

  getIt.registerFactory<FilterListBloc>(
    () => FilterListBloc(filterRepository: getIt<FilterRepository>()),
  );

  getIt.registerFactory<NotificationsBloc>(
    () => NotificationsBloc(filterRepository: getIt<FilterRepository>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
    ),
  );
}
