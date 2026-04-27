abstract class AuthenticationFailure implements Exception {
  final String message;
  final String? debugMessage;

  const AuthenticationFailure(this.message, {this.debugMessage});
}

class SignUpWithEmailAndPasswordFailure extends AuthenticationFailure {
  const SignUpWithEmailAndPasswordFailure._(super.message);

  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure._(
          'El correo no es válido.',
        );
      case 'user-disabled':
        return const SignUpWithEmailAndPasswordFailure._(
          'Este usuario ha sido deshabilitado.',
        );
      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure._(
          'Este correo ya está registrado.',
        );
      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure._(
          'Esta operación no está permitida.',
        );
      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure._(
          'La contraseña es demasiado débil.',
        );
      default:
        return const SignUpWithEmailAndPasswordFailure._(
          'Ocurrió un error inesperado durante el registro.',
        );
    }
  }
}

class LogInWithEmailAndPasswordFailure extends AuthenticationFailure {
  const LogInWithEmailAndPasswordFailure._(super.message);

  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure._(
          'El correo no es válido.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure._(
          'Este usuario ha sido deshabilitado.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure._(
          'No existe un usuario con este correo.',
        );
      case 'wrong-password':
      case 'invalid-credential':
        return const LogInWithEmailAndPasswordFailure._(
          'Correo o contraseña incorrectos.',
        );
      case 'too-many-requests':
        return const LogInWithEmailAndPasswordFailure._(
          'Demasiados intentos. Intenta de nuevo más tarde.',
        );
      default:
        return const LogInWithEmailAndPasswordFailure._(
          'Ocurrió un error inesperado al iniciar sesión.',
        );
    }
  }
}

class LogOutFailure extends AuthenticationFailure {
  const LogOutFailure()
      : super('Ocurrió un error al cerrar sesión.');
}
