import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';

class MockFirebaseUser extends Mock implements User {}

void main() {
  group('AppUser', () {
    test('empty returns AppUser with empty uid', () {
      const user = AppUser.empty;
      expect(user.uid, '');
      expect(user.email, isNull);
      expect(user.displayName, isNull);
      expect(user.photoURL, isNull);
    });

    test('constructor stores all fields correctly', () {
      const user = AppUser(
        uid: 'uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://photo.url',
      );

      expect(user.uid, 'uid-123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoURL, 'https://photo.url');
    });

    group('fromFirebaseUser', () {
      test('returns empty AppUser when firebaseUser is null', () {
        final result = AppUser.fromFirebaseUser(null);
        expect(result, equals(AppUser.empty));
        expect(result.uid, '');
      });

      test('maps all fields from a FirebaseUser', () {
        final mockUser = MockFirebaseUser();
        when(() => mockUser.uid).thenReturn('firebase-uid');
        when(() => mockUser.email).thenReturn('firebase@example.com');
        when(() => mockUser.displayName).thenReturn('Firebase User');
        when(() => mockUser.photoURL).thenReturn('https://photo.url');

        final result = AppUser.fromFirebaseUser(mockUser);

        expect(result.uid, 'firebase-uid');
        expect(result.email, 'firebase@example.com');
        expect(result.displayName, 'Firebase User');
        expect(result.photoURL, 'https://photo.url');
      });

      test('maps null optional fields from a FirebaseUser', () {
        final mockUser = MockFirebaseUser();
        when(() => mockUser.uid).thenReturn('firebase-uid');
        when(() => mockUser.email).thenReturn(null);
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUser.photoURL).thenReturn(null);

        final result = AppUser.fromFirebaseUser(mockUser);

        expect(result.uid, 'firebase-uid');
        expect(result.email, isNull);
        expect(result.displayName, isNull);
        expect(result.photoURL, isNull);
      });
    });

    group('toString', () {
      test('returns "AppUser: empty" for empty AppUser', () {
        expect(AppUser.empty.toString(), 'AppUser: empty');
      });

      test('returns full string for non-empty AppUser', () {
        const user = AppUser(
          uid: 'uid-123',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://photo.url',
        );
        expect(
          user.toString(),
          'AppUser(uid: uid-123, email: test@example.com, displayName: Test User, photoURL: https://photo.url)',
        );
      });
    });
  });
}
