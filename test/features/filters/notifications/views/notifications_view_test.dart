import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_bloc.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_event.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_state.dart';
import 'package:incauca_labs/features/filters/notifications/views/notifications_view.dart';
import 'package:incauca_labs/features/filters/detail/views/filter_detail_view.dart';

class MockNotificationsBloc extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}

void main() {
  late MockNotificationsBloc mockNotificationsBloc;

  setUp(() {
    mockNotificationsBloc = MockNotificationsBloc();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<NotificationsBloc>.value(
        value: mockNotificationsBloc,
        child: const Scaffold(body: NotificationsView()),
      ),
    );
  }

  group('NotificationsView', () {
    testWidgets('renders empty state correctly', (tester) async {
      when(() => mockNotificationsBloc.state).thenReturn(
        const NotificationsState(notifications: []),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('No hay notificaciones recientes'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('renders list of notifications and navigates to detail', (tester) async {
      final detail = FilterDetail(
        id: '1',
        imageUrl: 'url',
        impurityCount: 10,
        metal: 1,
        other: 2,
        firstEffect: 1,
        secondAndThirdEffect: 2,
        fourthEffect: 1,
        fifthEffect: 1,
        quality: 90,
        processedAt: DateTime(2024, 5, 4),
      );

      when(() => mockNotificationsBloc.state).thenReturn(
        NotificationsState(notifications: [detail]),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Nuevo Resultado #1'), findsOneWidget);
      expect(find.text('Impurezas: 10'), findsOneWidget);

      await tester.tap(find.text('Nuevo Resultado #1'));
      await tester.pumpAndSettle();

      expect(find.byType(FilterDetailView), findsOneWidget);
    });
  });
}
