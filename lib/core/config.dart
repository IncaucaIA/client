class AzureConfig {
  // Web PubSub Configuration
  static const String negotiateEndpoint = '/negotiate';
  static const String getUploadUrlEndpoint = '/generate_upload_urls';

  static const String apiBaseUrl =
      'https://incauca-linux-function-app.azurewebsites.net/api';

  // Cosmos DB Configuration
  static const String cosmosDbEndpoint =
      'https://incauca-cosmos-db-account-36104.documents.azure.com:443/';
  static const String cosmosDbKey =
      'sQlZs4yIkQ2rPbbbqtVxfsokrDiHkSGfRmSgxIi0PvKXxcL7w3bw0xrWr9jNkHDRvMMpwok5K3zVACDb0DtSIQ==';
  static const String databaseName = 'incauca-cosmosdb-database';
  static const String containerName = 'incauca-cosmosdb-container';

  // Azure Storage Configuration
  static const String storageAccountUrl =
      'https://storageaccount36104.blob.core.windows.net';
  static const String storageContainerName = 'images';
}
