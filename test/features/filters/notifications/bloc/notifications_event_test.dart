import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_event.dart';

void main() {
  group('NotificationsEvent', () {
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

    test('NotificationsStarted supports value equality', () {
      expect(NotificationsStarted(), NotificationsStarted());
    });

    test('NotificationReceived supports value equality', () {
      expect(
        NotificationReceived(testDetail),
        NotificationReceived(testDetail),
      );
      expect(
        NotificationReceived(testDetail).props,
        [testDetail],
      );
    });

    test('NotificationsCleared supports value equality', () {
      expect(NotificationsCleared(), NotificationsCleared());
    });
  });
}
