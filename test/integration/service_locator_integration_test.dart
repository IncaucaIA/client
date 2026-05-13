import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/core/service_locator.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_bloc.dart';
import 'package:incauca_labs/features/auth/domain/auth_repository.dart';
import 'package:incauca_labs/features/filters/domain/filter_repository.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_bloc.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_bloc.dart';
import 'package:incauca_labs/features/filters/domain/websocket_datasource.dart';
import 'package:incauca_labs/features/filters/data/local_websocket_datasource_impl.dart';

void main() {
  setUp(() {
    GetIt.instance.reset();
  });

  group('ServiceLocator Integration Tests (Test 7)', () {
    test('Test 7: ServiceLocator registra el grafo completo en modo local sin errores', () {
      AppConfig.setEnvironmentForTesting('local');
      AppConfig.initialize();
      
      // We do not resolve FirebaseAuth here so it will not crash
      setupServiceLocator();

      expect(getIt.isRegistered<http.Client>(), isTrue);
      expect(getIt.isRegistered<WebSocketDatasource>(), isTrue);
      expect(getIt.isRegistered<FilterRepository>(), isTrue);
      expect(getIt.isRegistered<AuthRepository>(), isTrue);
      expect(getIt.isRegistered<FilterListBloc>(), isTrue);
      expect(getIt.isRegistered<NotificationsBloc>(), isTrue);
      expect(getIt.isRegistered<AuthBloc>(), isTrue);

      final wsSource = getIt<WebSocketDatasource>();
      expect(wsSource, isA<LocalWebSocketDatasourceImpl>());

      final filterListBloc = getIt<FilterListBloc>();
      expect(filterListBloc, isNotNull);

      final notificationsBloc = getIt<NotificationsBloc>();
      expect(notificationsBloc, isNotNull);

      final authBloc = getIt<AuthBloc>();
      expect(authBloc, isNotNull);
    });
  });
}
