import 'dart:io';

class AppConfig {
  static String get baseUrl {
    if (Platform.isAndroid) return '10.147.17.100:8000';
    return '10.147.17.100:8000';
  }

  static String get apiBaseUrl => 'http://$baseUrl/api';
  static String get wsEndpoint => 'ws://$baseUrl/ws/results';
  static String get uploadEndpoint => '/analysis/upload';
}
