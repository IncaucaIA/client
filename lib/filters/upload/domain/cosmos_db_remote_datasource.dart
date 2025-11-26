import 'package:incauca_labs/filters/upload/domain/models/image_document.dart';

abstract class CosmosDbRemoteDatasource {
  /// Creates a new document in Azure Cosmos DB
  /// Returns the created document
  Future<ImageDocument> createDocument(ImageDocument document);
}
