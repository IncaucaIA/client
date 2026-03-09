import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart'; // Asegúrate de tener tus configs aquí
import 'package:incauca_labs/filters/upload/domain/storage_remote_datasource.dart';
import 'package:path/path.dart' as path;

class StorageRemoteDatasourceImpl implements StorageRemoteDatasource {
  final http.Client httpClient;

  StorageRemoteDatasourceImpl({required this.httpClient});

  @override
  Future<String> uploadImage(File image) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.uploadEndpoint}');
      final request = http.MultipartRequest('POST', uri);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // backend expects 'file' parameter
          image.path,
        ),
      );

      final streamedResponse = await httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // The backend returns { "status": "ok", "result": { ..., "imageUrl": "..." } }
        return data['result']['imageUrl'] as String;
      } else {
        throw Exception(
          'Error subiendo al microservicio (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
