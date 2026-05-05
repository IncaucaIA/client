import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/auth/application/shared/inputs/confirm_password.dart';

void main() {
  group('ConfirmedPassword', () {
    test('pure constructor creates an empty, valid input', () {
      const password = ConfirmedPassword.pure();
      expect(password.value, '');
      expect(password.password, '');
      expect(password.isPure, true);
    });

    test('dirty constructor creates an input with given value', () {
      const password = ConfirmedPassword.dirty(password: '123', value: '123');
      expect(password.value, '123');
      expect(password.password, '123');
      expect(password.isPure, false);
    });

    test('validator returns mismatch when values do not match', () {
      const password = ConfirmedPassword.dirty(password: '123', value: '1234');
      expect(password.error, ConfirmedPasswordValidationError.mismatch);
    });

    test('validator returns null when values match', () {
      const password = ConfirmedPassword.dirty(password: '123', value: '123');
      expect(password.error, isNull);
    });

    test('error message is correct', () {
      expect(ConfirmedPasswordValidationError.mismatch.message, 'errors.auth.passwords_do_not_match');
    });
  });
}
