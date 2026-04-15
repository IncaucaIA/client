import 'package:firebase_auth/firebase_auth.dart';
import 'package:incauca_labs/features/auth/data/dtos/register_dto.dart';
import 'package:incauca_labs/features/auth/domain/datasources_def/user_datasource_def.dart';
import 'package:incauca_labs/features/auth/domain/entities/user_profile.dart';
import 'package:incauca_labs/features/auth/domain/failures/user_failures.dart';
import 'package:incauca_labs/features/auth/domain/services_def/auth_service_def.dart';
import 'package:incauca_labs/features/auth/domain/services_def/user_service_def.dart';


class UserServiceImpl implements UserService {
  final AuthenticationService _authService;
  final UserDataSource _userDataSource;

  UserServiceImpl({
    required AuthenticationService authService,
    required UserDataSource userDataSource,
  }) : _authService = authService,
       _userDataSource = userDataSource;

  Future<String> _getCurrentUserId() async {
    final id = await _authService.getCurrentUserId();
    if (id == null) throw const InvalidUserIdFailure();
    return id;
  }

  Future<User> _getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw const InvalidUserIdFailure();
    return user;
  }

  @override
  Future<bool> doesUserExist(String uid) async {
    try {
      return await _userDataSource.doesUserExist(uid);
    } on UserFailure {
      rethrow;
    } catch (_) {
      throw const UserProfileConversionFailure();
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final dto = await _userDataSource.getUserProfile(uid);
      return dto?.toDomain();
    } on UserFailure {
      rethrow;
    } catch (_) {
      throw const UserProfileConversionFailure();
    }
  }

  @override
  Future<void> registerUser() async {
    final dto = UserInitialRegistrationInputDTO();
    try {
      final uid = await _getCurrentUserId();
      await _userDataSource.setUser(uid, dto.toJson());
    } on UserFailure {
      rethrow;
    } catch (_) {
      throw const UserCreationFailure();
    }
  }

}
