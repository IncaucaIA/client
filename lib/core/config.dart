import 'config_strategy.dart';

class AppConfig {
  static final String _environment = const String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'local',
  ).toLowerCase();

  static late final ConfigStrategy _strategy;

  static void initialize() {
    print('🚀 Initializing AppConfig for environment: $_environment');
    if (_environment == 'cloud') {
      _strategy = CloudConfigStrategy();
    } else {
      _strategy = LocalConfigStrategy();
    }
  }

  static ConfigStrategy get strategy => _strategy;

  // Helpers for direct access if preferred
  static String get apiBaseUrl => _strategy.apiBaseUrl;
  static bool get isCloud => _strategy.isCloud;
  
  // Azure specific
  static String? get negotiateEndpoint => _strategy.negotiateEndpoint;
  static String? get getUploadUrlEndpoint => _strategy.getUploadUrlEndpoint;
  
  // Local specific
  static String? get wsEndpoint => _strategy.wsEndpoint;
  static String? get uploadEndpoint => _strategy.uploadEndpoint;
}
