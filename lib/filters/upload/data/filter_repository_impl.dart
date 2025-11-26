import 'dart:io';
import 'package:incauca_labs/filters/upload/domain/filter_repository.dart';
import 'package:incauca_labs/filters/upload/domain/models/image_document.dart';
import 'package:incauca_labs/filters/upload/domain/storage_remote_datasource.dart';
import 'package:incauca_labs/filters/upload/domain/cosmos_db_remote_datasource.dart';
import 'package:incauca_labs/filters/upload/domain/websocket_datasource.dart';
import 'package:uuid/uuid.dart';

class FilterRepositoryImpl implements FilterRepository {
  final StorageRemoteDatasource storageDataSource;
  final CosmosDbRemoteDatasource cosmosDbDataSource;
  final WebSocketDatasource webSocketDataSource;
  final Uuid uuid;

  FilterRepositoryImpl({
    required this.storageDataSource,
    required this.cosmosDbDataSource,
    required this.webSocketDataSource,
    required this.uuid,
  });

  @override
  Future<ImageDocument> uploadImageWithMetadata({
    required File image,
    required String userId,
    List<String> tags = const [],
  }) async {
    try {
      // Step 1: Upload image to Azure Blob Storage
      final imageUrl = await storageDataSource.uploadImage(image);

      // Step 2: Create document in Cosmos DB
      final document = ImageDocument(
        id: uuid.v4(),
        image: ImageInfo(
          url: imageUrl,
          uploadedAt: DateTime.now().toUtc().toIso8601String(),
        ),
        aiResults: const [], // Will be populated by backend AI processing
        metadata: ImageMetadata(userId: userId, tags: tags),
      );

      final createdDocument = await cosmosDbDataSource.createDocument(document);

      return createdDocument;
    } catch (e) {
      throw Exception('Failed to upload image with metadata: $e');
    }
  }

  @override
  Stream<String> listenToNotifications() {
    return webSocketDataSource.getMessageStream();
  }

  @override
  Future<void> connectToNotifications() async {
    await webSocketDataSource.connect();
  }

  @override
  Future<void> disconnectFromNotifications() async {
    await webSocketDataSource.disconnect();
  }
}
