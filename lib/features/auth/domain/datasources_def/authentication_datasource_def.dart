import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationDataSource {
  Future<User?> signUp(String email, String password);
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
}