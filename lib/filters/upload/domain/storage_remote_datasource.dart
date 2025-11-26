import 'dart:io';

abstract class StorageRemoteDatasource {
  /// Uploads an image file to Azure Blob Storage
  /// Returns the URL of the uploaded image
  Future<String> uploadImage(File image);
}
