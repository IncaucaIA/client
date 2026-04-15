import 'package:firebase_auth/firebase_auth.dart';
import 'package:incauca_labs/features/auth/domain/datasources_def/authentication_datasource_def.dart';
import 'package:incauca_labs/features/auth/domain/failures/authentication_failures.dart';


class AuthenticationDataSourceImpl implements AuthenticationDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthenticationDataSourceImpl({
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  @override
  Future<User?> signUp(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (e) {
      throw SignUpWithEmailAndPasswordFailure;
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (e) {
      throw LogInWithEmailAndPasswordFailure;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut()]);
    } catch (_) {
      throw const LogOutFailure();
    }
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}