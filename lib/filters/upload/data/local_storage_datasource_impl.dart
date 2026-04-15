import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/filters/upload/domain/storage_remote_datasource.dart';

class LocalStorageRemoteDatasourceImpl implements StorageRemoteDatasource {
  final http.Client httpClient;

  LocalStorageRemoteDatasourceImpl({required this.httpClient});

  @override
  Future<String> uploadImage(File image) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.uploadEndpoint}');
      final request = http.MultipartRequest('POST', uri);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', 
          image.path,
        ),
      );

      final streamedResponse = await httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['result']['imageUrl'] as String;
      } else {
        throw Exception(
          'Error uploading to local microservice (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload image locally: $e');
    }
  }
}
