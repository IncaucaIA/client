class AzureConfig {
  // Web PubSub Configuration
  static const String negotiateEndpoint =
      'https://incauca-linux-function-app.azurewebsites.net/api/negotiate';

  // Cosmos DB Configuration
  static const String cosmosDbEndpoint =
      'https://incauca-cosmos-db-account-36104.documents.azure.com:443/';
  static const String cosmosDbKey =
      'HkMmYkwPo1DZJi1ch4r0uB7G8Lr1SoiI9aBWsUFXExN2adSR7SIzoieflYh7mVZPUEcMyre0JdDRACDbJx7Erw==';
  static const String databaseName = 'incauca-cosmosdb-database';
  static const String containerName = 'incauca-cosmosdb-container';

  // Azure Storage Configuration (placeholder - update with actual values)
  static const String storageAccountUrl =
      'https://storageaccount36104.blob.core.windows.net';
  static const String storageContainerName = 'images';
}
