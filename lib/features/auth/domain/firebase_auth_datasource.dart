import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseAuthDatasource {
  Stream<User?> sessionChanges();
  Future<UserCredential> interactiveSignIn(String email, String password);
  Future<void> signOut();
}
