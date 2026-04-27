import 'package:formz/formz.dart';

enum EmailValidationError {
  required('errors.auth.empty_email'),
  invalid('errors.auth.invalid_email');

  final String key;
  const EmailValidationError(this.key);

  String get message => key;
}

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');
  const Email.dirty([String value = '']) : super.dirty(value);

  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
  );

  @override
  EmailValidationError? validator(String value) {
    return value.isEmpty
        ? EmailValidationError.required
        : _emailRegex.hasMatch(value)
        ? null
        : EmailValidationError.invalid;
  }
}