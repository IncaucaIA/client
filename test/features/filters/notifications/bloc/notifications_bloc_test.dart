import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incauca_labs/features/filters/domain/filter_repository.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_bloc.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_event.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_state.dart';

class MockFilterRepository extends Mock implements FilterRepository {}

void main() {
  late MockFilterRepository filterRepository;
  late NotificationsBloc notificationsBloc;
  late StreamController<String> controller;

  final testDetail = FilterDetail(
    id: '1',
    imageUrl: 'url1',
    impurityCount: 5,
    metal: 1,
    other: 2,
    firstEffect: 1,
    secondAndThirdEffect: 2,
    fourthEffect: 1,
    fifthEffect: 1,
    quality: 90,
    processedAt: DateTime(2024, 5, 4),
  );

  setUp(() {
    filterRepository = MockFilterRepository();
    controller = StreamController<String>.broadcast();
    when(() => filterRepository.listenToNotifications())
        .thenAnswer((_) => controller.stream);
    notificationsBloc = NotificationsBloc(filterRepository: filterRepository);
  });

  tearDown(() {
    controller.close();
    notificationsBloc.close();
  });

  group('NotificationsBloc', () {
    test('initial state is correct', () {
      expect(notificationsBloc.state, const NotificationsState());
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'starts listening and adds NotificationReceived when data is received',
      build: () => notificationsBloc,
      act: (bloc) async {
        bloc.add(NotificationsStarted());
        await Future.delayed(Duration.zero);
        controller.add('{"id": "1", "image": {"url": "url1", "uploadedAt": "2024-05-04T00:00:00.000"}, "aiResults": [{"impurityCount": 5, "metal": 1, "other": 2, "firstEffect": 1, "secondAndThirdEffect": 2, "fourthEffect": 1, "fifthEffect": 1, "quality": 90}]}');
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        NotificationsState(notifications: [testDetail]),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'ignores invalid json data',
      build: () => notificationsBloc,
      act: (bloc) async {
        bloc.add(NotificationsStarted());
        await Future.delayed(Duration.zero);
        controller.add('invalid json');
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'clears notifications when NotificationsCleared is added',
      build: () => notificationsBloc,
      seed: () => NotificationsState(notifications: [testDetail]),
      act: (bloc) => bloc.add(NotificationsCleared()),
      expect: () => [
        const NotificationsState(),
      ],
    );
  });
}
