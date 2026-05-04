import '../domain/auth_repository.dart';
import '../domain/auth_datasource.dart';
import '../domain/entities/app_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<AppUser> signIn(String email, String password) {
    return _datasource.signIn(email, password);
  }

  @override
  Future<void> signOut() {
    return _datasource.signOut();
  }
}
