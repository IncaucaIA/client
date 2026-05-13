import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incauca_labs/features/filters/domain/filter_repository.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_bloc.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_event.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_state.dart';

import 'package:incauca_labs/core/config.dart';

class MockFilterRepository extends Mock implements FilterRepository {}

void main() {
  late MockFilterRepository mockRepository;
  late NotificationsBloc bloc;
  late StreamController<String> wsController;

  setUp(() {
    AppConfig.initialize();
    mockRepository = MockFilterRepository();
    wsController = StreamController<String>.broadcast();
    when(() => mockRepository.listenToNotifications()).thenAnswer((_) => wsController.stream);
    
    bloc = NotificationsBloc(filterRepository: mockRepository);
  });

  tearDown(() {
    bloc.close();
    wsController.close();
  });

  group('NotificationsBloc Integration Tests (Test 6)', () {
    test('Test 6: NotificationsBloc parsea mensajes WS y mantiene lista ordenada', () async {
      // Dispatch Started
      bloc.add(NotificationsStarted());

      // Let stream connection initialize
      await Future.delayed(const Duration(milliseconds: 50));

      final validJson1 = '{"imageId":"1","createdAt":"2026-05-12T10:00:00Z","status":"pending","impurityDetection":{"overallPurity":0.9}}';
      final validJson2 = '{"id":"2","createdAt":"2026-05-12T10:05:00Z","status":"processed","aiResults":[{"purityScore":0.8}]}';
      final invalidJson = '{"malformed":"json"';

      // 1. Emit valid JSON 1
      wsController.add(validJson1);

      await expectLater(
        bloc.stream,
        emitsThrough(isA<NotificationsState>().having((s) => s.notifications.length, 'length', 1)
                                              .having((s) => s.notifications.first.id, 'id', '1')),
      );

      // 2. Emit valid JSON 2
      wsController.add(validJson2);

      await expectLater(
        bloc.stream,
        emitsThrough(isA<NotificationsState>().having((s) => s.notifications.length, 'length', 2)
                                              .having((s) => s.notifications.first.id, 'first id', '2')), // Newest first
      );

      // 3. Emit malformed JSON
      wsController.add(invalidJson);

      // We expect the state not to change. Since we can't easily expect *no* emission if we just wait, 
      // we can wait a bit and check state directly
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.notifications.length, 2);
    });
  });
}
