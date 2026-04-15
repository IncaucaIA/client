import 'package:formz/formz.dart';

enum PasswordValidationError {
  empty('errors.auth.empty_password'),
  invalid('errors.auth.weak_password');

  final String key;
  const PasswordValidationError(this.key);

  String get message => key;
}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');

  const Password.dirty([super.value = '']) : super.dirty();

  static final passwordRegExp =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

  @override
  PasswordValidationError? validator(String? value) {
    if (value == '' || value == null) {
      return PasswordValidationError.empty;
    } else {
      return passwordRegExp.hasMatch(value)
          ? null
          : PasswordValidationError.invalid;
    }
  }
}