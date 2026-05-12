// coverage:ignore-file
import 'entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn(String email, String password);
  Future<void> signOut();
}
