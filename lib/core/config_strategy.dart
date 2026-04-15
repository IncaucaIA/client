abstract class ConfigStrategy {
  String get apiBaseUrl;
  String? get negotiateEndpoint;
  String? get getUploadUrlEndpoint;
  String? get wsEndpoint;
  String? get uploadEndpoint;
  bool get isCloud;

  // Cosmos DB (Optional for Cloud)
  String? get cosmosDbEndpoint;
  String? get cosmosDbKey;
  String? get databaseName;
  String? get containerName;

  // Storage (Optional for Cloud)
  String? get storageAccountUrl;
  String? get storageContainerName;
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

  @override
  String get cosmosDbEndpoint => const String.fromEnvironment(
        'COSMOS_DB_ENDPOINT',
        defaultValue: 'https://incauca-cosmos-db-account-36104.documents.azure.com:443/',
      );

  @override
  String get cosmosDbKey => const String.fromEnvironment(
        'COSMOS_DB_KEY',
        defaultValue: 'sQlZs4yIkQ2rPbbbqtVxfsokrDiHkSGfRmSgxIi0PvKXxcL7w3bw0xrWr9jNkHDRvMMpwok5K3zVACDb0DtSIQ==',
      );

  @override
  String get databaseName => const String.fromEnvironment(
        'COSMOS_DB_DATABASE',
        defaultValue: 'incauca-cosmosdb-database',
      );

  @override
  String get containerName => const String.fromEnvironment(
        'COSMOS_DB_CONTAINER',
        defaultValue: 'incauca-cosmosdb-container',
      );

  @override
  String get storageAccountUrl => const String.fromEnvironment(
        'STORAGE_ACCOUNT_URL',
        defaultValue: 'https://storageaccount36104.blob.core.windows.net',
      );

  @override
  String get storageContainerName => const String.fromEnvironment(
        'STORAGE_CONTAINER_NAME',
        defaultValue: 'images',
      );
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

  @override
  String? get cosmosDbEndpoint => null;

  @override
  String? get cosmosDbKey => null;

  @override
  String? get databaseName => null;

  @override
  String? get containerName => null;

  @override
  String? get storageAccountUrl => null;

  @override
  String? get storageContainerName => null;
}
