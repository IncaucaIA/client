import 'package:incauca_labs/features/auth/domain/entities/user_profile.dart';

abstract class UserService {

  Future<void> registerUser();

  Future<bool> doesUserExist(String uid);

  Future<UserProfile?> getUserProfile(String uid);
}