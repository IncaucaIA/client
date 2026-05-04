import 'entities/app_user.dart';

abstract class AuthDatasource {
  Future<AppUser> signIn(String email, String password);
  Future<void> signOut();
}
