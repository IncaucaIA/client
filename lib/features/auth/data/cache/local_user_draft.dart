import 'dart:convert';
import 'package:incauca_labs/features/auth/data/dtos/user_dto.dart';
import 'package:incauca_labs/features/auth/domain/entities/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserDraft {
  static const _draftKey = 'local_user_draft';
  static const _uidKey = 'local_user_draft_uid';
  static const _emailKey = 'local_user_draft_email';

  static Future<void> save({
    required UserProfile profile,
    required String uid,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dto = UserDTO.fromDomain(
      profile,
      id: uid,
      email: email,
    );
    await prefs.setString(_draftKey, jsonEncode(dto.toJson()));
    await prefs.setString(_uidKey, uid);
    await prefs.setString(_emailKey, email);
  }

  static Future<UserProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_draftKey);
    final uid = prefs.getString(_uidKey);
    if (jsonString == null || uid == null) return null;

    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    final dto = UserDTO.fromMap(map, id: uid);
    return dto.toDomain();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
    await prefs.remove(_uidKey);
    await prefs.remove(_emailKey);
  }
}