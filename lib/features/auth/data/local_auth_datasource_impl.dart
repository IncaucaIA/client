import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart';
import '../domain/auth_datasource.dart';
import '../domain/entities/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthDatasourceImpl implements AuthDatasource {
  final http.Client _httpClient;
  static const _tokenKey = 'access_token';

  LocalAuthDatasourceImpl({required http.Client httpClient}) : _httpClient = httpClient;

  @override
  Future<AppUser> signIn(String email, String password) async {
    final baseUrl = AppConfig.apiBaseUrl;
    final url = Uri.parse('$baseUrl/auth/login');
    print('🔑 Local Auth: Attempting login at $url');

    final response = await _httpClient.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String accessToken = data['access_token'];
      
      // Store the token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, accessToken);

      // In this local flow, we might not have full user info in the token response
      // For now, return an AppUser with the email as display name or similar
      return AppUser(
        uid: email, // Using email as UID for now if backend doesn't provide it
        email: email,
        displayName: email.split('@').first,
      );
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Helper to get the token for other requests
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
