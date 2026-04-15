sealed class UserFailure implements Exception {
  final String message;
  final String? debugMessage;

  const UserFailure(this.message, {this.debugMessage});
}

class UserNotFoundFailure extends UserFailure {
  const UserNotFoundFailure() : super(
    'El usuario no existe.',
  );
}

class UserUpdateFailure extends UserFailure {
  const UserUpdateFailure({String? debugMessage})
      : super(
          'No se pudo actualizar la información del usuario.',
          debugMessage: debugMessage,
        );
}

class UserCreationFailure extends UserFailure {
  const UserCreationFailure({String? debugMessage})
      : super(
          'No se pudo crear el usuario.',
          debugMessage: debugMessage,
        );
}

class InvalidUserIdFailure extends UserFailure {
  const InvalidUserIdFailure() : super(
    'El ID de usuario no es válido.',
  );
}

class UserProfileConversionFailure extends UserFailure {
  const UserProfileConversionFailure()
      : super(
          'No se pudo convertir el perfil del usuario.',
        );
}
