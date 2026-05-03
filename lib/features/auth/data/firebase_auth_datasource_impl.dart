import 'package:firebase_auth/firebase_auth.dart';
import '../domain/firebase_auth_datasource.dart';

class FirebaseAuthDatasourceImpl implements FirebaseAuthDatasource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDatasourceImpl(this._firebaseAuth);

  @override
  Stream<User?> sessionChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<UserCredential> interactiveSignIn(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
