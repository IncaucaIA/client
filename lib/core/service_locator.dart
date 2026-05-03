import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../filters/upload/domain/storage_remote_datasource.dart';
import '../filters/upload/domain/websocket_datasource.dart';
import '../filters/upload/domain/filter_repository.dart';
import '../filters/upload/data/azure_storage_datasource_impl.dart';
import '../filters/upload/data/local_storage_datasource_impl.dart';
import '../filters/upload/data/azure_websocket_datasource_impl.dart';
import '../filters/upload/data/local_websocket_datasource_impl.dart';
import '../filters/upload/data/filter_repository_impl.dart';
import '../filters/upload/application/bloc/upload_bloc.dart';
import 'config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/domain/firebase_auth_datasource.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/data/firebase_auth_datasource_impl.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/application/bloc/auth_bloc.dart';
import '../features/auth/application/bloc/auth_validator.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // External dependencies
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<Uuid>(() => const Uuid());
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<AuthValidator>(() => AuthValidator());

  // Data sources
  if (AppConfig.isCloud) {
    getIt.registerLazySingleton<StorageRemoteDatasource>(
      () => AzureStorageRemoteDatasourceImpl(httpClient: getIt<http.Client>()),
    );
    getIt.registerLazySingleton<WebSocketDatasource>(
      () => AzureWebSocketDatasourceImpl(httpClient: getIt<http.Client>()),
    );
  } else {
    getIt.registerLazySingleton<StorageRemoteDatasource>(
      () => LocalStorageRemoteDatasourceImpl(httpClient: getIt<http.Client>()),
    );
    getIt.registerLazySingleton<WebSocketDatasource>(
      () => LocalWebSocketDatasourceImpl(httpClient: getIt<http.Client>()),
    );
  }

  // Auth Data sources
  getIt.registerLazySingleton<FirebaseAuthDatasource>(
    () => FirebaseAuthDatasourceImpl(getIt<FirebaseAuth>()),
  );

  // Repository
  getIt.registerLazySingleton<FilterRepository>(
    () => FilterRepositoryImpl(
      storageDataSource: getIt<StorageRemoteDatasource>(),
      webSocketDataSource: getIt<WebSocketDatasource>(),
      uuid: getIt<Uuid>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuthDatasource>()),
  );

  // BLoC - registered as factory to create new instances when needed
  getIt.registerFactory<UploadBloc>(
    () => UploadBloc(repository: getIt<FilterRepository>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
      validator: getIt<AuthValidator>(),
    ),
  );
}
