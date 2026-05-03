import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_repository.dart';
import '../domain/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<UserCredential> signIn(String email, String password) {
    return _datasource.interactiveSignIn(email, password);
  }

  @override
  Future<void> signOut() {
    return _datasource.signOut();
  }

  @override
  Stream<User?> watchSession() {
    return _datasource.sessionChanges();
  }
}
