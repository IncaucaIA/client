import 'package:incauca_labs/features/auth/data/dtos/user_dto.dart';

abstract class UserDataSource {

  Future<UserDTO?> getUserProfile(String uid);

  Future<bool> doesUserExist(String uid);

  Future<void> setUser(String uid, Map<String, dynamic> data);

}