import 'package:formz/formz.dart';

enum ConfirmedPasswordValidationError {
  mismatch('errors.auth.passwords_do_not_match');

  final String key;
  const ConfirmedPasswordValidationError(this.key);

  String get message => key;
}


class ConfirmedPassword extends FormzInput<String, ConfirmedPasswordValidationError> {
  final String password;

  const ConfirmedPassword.pure({this.password = ''}) : super.pure('');
  const ConfirmedPassword.dirty({this.password = '', String value = ''}) : super.dirty(value);

  @override
  ConfirmedPasswordValidationError? validator(String value) {
    return value == password ? null : ConfirmedPasswordValidationError.mismatch;
  }
}