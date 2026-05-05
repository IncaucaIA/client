import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/auth/application/shared/inputs/email.dart';

void main() {
  group('Email', () {
    test('pure constructor creates an empty, valid input', () {
      const email = Email.pure();
      expect(email.value, '');
      expect(email.isPure, true);
    });

    test('dirty constructor creates an input with given value', () {
      const email = Email.dirty('test@test.com');
      expect(email.value, 'test@test.com');
      expect(email.isPure, false);
    });

    test('validator returns required when value is empty', () {
      const email = Email.dirty('');
      expect(email.error, EmailValidationError.required);
    });

    test('validator returns invalid when value is not a valid email', () {
      const email = Email.dirty('test');
      expect(email.error, EmailValidationError.invalid);
    });

    test('validator returns null when value is a valid email', () {
      const email = Email.dirty('test@example.com');
      expect(email.error, isNull);
    });

    test('error messages are correct', () {
      expect(EmailValidationError.required.message, 'errors.auth.empty_email');
      expect(EmailValidationError.invalid.message, 'errors.auth.invalid_email');
    });
  });
}
