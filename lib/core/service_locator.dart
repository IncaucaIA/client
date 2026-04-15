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

final getIt = GetIt.instance;

void setupServiceLocator() {
  // External dependencies
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<Uuid>(() => const Uuid());

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

  // Repository
  getIt.registerLazySingleton<FilterRepository>(
    () => FilterRepositoryImpl(
      storageDataSource: getIt<StorageRemoteDatasource>(),
      webSocketDataSource: getIt<WebSocketDatasource>(),
      uuid: getIt<Uuid>(),
    ),
  );

  // BLoC - registered as factory to create new instances when needed
  getIt.registerFactory<UploadBloc>(
    () => UploadBloc(repository: getIt<FilterRepository>()),
  );
}
