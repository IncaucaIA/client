import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/filters/upload/domain/storage_remote_datasource.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class AzureStorageRemoteDatasourceImpl implements StorageRemoteDatasource {
  final http.Client httpClient;

  AzureStorageRemoteDatasourceImpl({required this.httpClient});

  @override
  Future<String> uploadImage(File image) async {
    try {
      final fileExtension = path.extension(image.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      final uploadUrl = await _getUploadUrlFromBackend(fileName);

      final fileBytes = await image.readAsBytes();
      final mimeType = lookupMimeType(image.path) ?? 'application/octet-stream';

      final uri = Uri.parse(uploadUrl);

      final response = await httpClient.put(
        uri,
        headers: {
          'x-ms-blob-type': 'BlockBlob',
          'Content-Type': mimeType,
        },
        body: fileBytes,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Return clean URL (origin + path)
        return uri.origin + uri.path;
      } else {
        throw Exception(
          'Error uploading to Azure (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload image to Azure: $e');
    }
  }

  Future<String> _getUploadUrlFromBackend(String fileName) async {
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}${AppConfig.getUploadUrlEndpoint}',
    ).replace(queryParameters: {'filename': fileName});

    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      throw Exception(
        'Could not get upload URL: ${response.statusCode}',
      );
    }
  }
}
