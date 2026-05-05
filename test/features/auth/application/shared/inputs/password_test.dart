import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/auth/application/shared/inputs/password.dart';

void main() {
  group('Password', () {
    test('pure constructor creates an empty, valid input', () {
      const password = Password.pure();
      expect(password.value, '');
      expect(password.isPure, true);
    });

    test('dirty constructor creates an input with given value', () {
      const password = Password.dirty('Test@1234');
      expect(password.value, 'Test@1234');
      expect(password.isPure, false);
    });

    test('validator returns empty when value is empty string', () {
      const password = Password.dirty('');
      expect(password.error, PasswordValidationError.empty);
    });

    test('validator returns empty when value is null', () {
      const password = Password.pure();
      expect(password.validator(null), PasswordValidationError.empty);
    });

    test('validator returns invalid when value does not meet requirements', () {
      const password = Password.dirty('test');
      expect(password.error, PasswordValidationError.invalid);
    });

    test('validator returns null when value meets requirements', () {
      const password = Password.dirty('Test@1234');
      expect(password.error, isNull);
    });

    test('error messages are correct', () {
      expect(PasswordValidationError.empty.message, 'errors.auth.empty_password');
      expect(PasswordValidationError.invalid.message, 'errors.auth.weak_password');
    });
  });
}
