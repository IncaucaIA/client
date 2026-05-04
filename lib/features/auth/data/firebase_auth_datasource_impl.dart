import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_datasource.dart';
import '../domain/entities/app_user.dart';

class FirebaseAuthDatasourceImpl implements AuthDatasource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDatasourceImpl(this._firebaseAuth);

  @override
  Future<AppUser> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppUser.fromFirebaseUser(credential.user);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
