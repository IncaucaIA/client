import 'package:incauca_labs/features/auth/data/datasources_impl/cosmosdbClient.dart';
import 'package:incauca_labs/features/auth/data/dtos/user_dto.dart';
import 'package:incauca_labs/features/auth/domain/datasources_def/user_datasource_def.dart';
import 'package:incauca_labs/features/auth/domain/failures/user_failures.dart';

class UserDataSourceImpl implements UserDataSource {
  final CosmosDBClient _client;

  UserDataSourceImpl({required CosmosDBClient client})
      : _client = client;

  @override
  Future<UserDTO?> getUserProfile(String uid) async {
    try {
      final doc = await _client.getDocument(uid);

      if (doc == null) return null;

      return UserDTO.fromMap(doc, id: uid);
    } catch (e) {
      throw UserProfileConversionFailure();
    }
  }

  @override
  Future<void> setUser(String uid, Map<String, dynamic> data) async {
    try {
      await _client.upsertDocument(uid, data);
    } catch (e) {
      throw UserCreationFailure(debugMessage: e.toString());
    }
  }

  @override
  Future<bool> doesUserExist(String uid) async {
    try {
      final doc = await _client.getDocument(uid);
      return doc != null;
    } catch (e) {
      throw UserProfileConversionFailure();
    }
  }
}