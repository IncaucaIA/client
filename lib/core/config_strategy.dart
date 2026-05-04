abstract class ConfigStrategy {
  String get apiBaseUrl;
  String? get negotiateEndpoint;
  String? get getUploadUrlEndpoint;
  String? get wsEndpoint;
  String? get uploadEndpoint;
  bool get isCloud;
}

class CloudConfigStrategy implements ConfigStrategy {
  @override
  String get apiBaseUrl => const String.fromEnvironment(
        'AZURE_API_BASE_URL',
        defaultValue: 'https://incauca-linux-function-app.azurewebsites.net/api',
      );

  @override
  String get negotiateEndpoint => const String.fromEnvironment(
        'AZURE_NEGOTIATE_ENDPOINT',
        defaultValue: '/negotiate',
      );

  @override
  String get getUploadUrlEndpoint => const String.fromEnvironment(
        'AZURE_GENERATE_UPLOAD_URL_ENDPOINT',
        defaultValue: '/generate_upload_urls',
      );

  @override
  String? get wsEndpoint => null;

  @override
  String? get uploadEndpoint => null;

  @override
  bool get isCloud => true;

}

class LocalConfigStrategy implements ConfigStrategy {
  static const String _defaultBaseUrl = '10.147.17.100:8000';

  @override
  String get apiBaseUrl {
    final baseUrl = const String.fromEnvironment(
      'LOCAL_BASE_URL',
      defaultValue: _defaultBaseUrl,
    );
    return 'http://$baseUrl/api';
  }

  @override
  String? get negotiateEndpoint => null;

  @override
  String? get getUploadUrlEndpoint => null;

  @override
  String get wsEndpoint {
    final baseUrl = const String.fromEnvironment(
      'LOCAL_BASE_URL',
      defaultValue: _defaultBaseUrl,
    );
    return 'ws://$baseUrl/ws/results';
  }

  @override
  String get uploadEndpoint => const String.fromEnvironment(
        'LOCAL_UPLOAD_ENDPOINT',
        defaultValue: '/analysis/upload',
      );

  @override
  bool get isCloud => false;
}
