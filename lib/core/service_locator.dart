import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../filters/upload/domain/storage_remote_datasource.dart';
import '../filters/upload/domain/websocket_datasource.dart';
import '../filters/upload/domain/filter_repository.dart';
import '../filters/upload/data/storage_remote_datasource_impl.dart';
import '../filters/upload/data/websocket_datasource_impl.dart';
import '../filters/upload/data/filter_repository_impl.dart';
import '../filters/upload/application/bloc/upload_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // External dependencies
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<Uuid>(() => const Uuid());

  // Data sources
  getIt.registerLazySingleton<StorageRemoteDatasource>(
    () => StorageRemoteDatasourceImpl(httpClient: getIt<http.Client>()),
  );

  getIt.registerLazySingleton<WebSocketDatasource>(
    () => WebSocketDatasourceImpl(httpClient: getIt<http.Client>()),
  );

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
