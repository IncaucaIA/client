import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart'; // Asegúrate de tener tus configs aquí
import 'package:incauca_labs/filters/upload/domain/storage_remote_datasource.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart'; // Recomendado agregar paquete: mime

class StorageRemoteDatasourceImpl implements StorageRemoteDatasource {
  final http.Client httpClient;

  StorageRemoteDatasourceImpl({required this.httpClient});

  @override
  Future<String> uploadImage(File image) async {
    try {
      final fileName = path.basename(image.path);

      // 1. Obtener la URL firmada (SAS) desde tu Backend
      // El backend debe devolver la URL completa donde subir:
      // ej: https://tuceuta.blob.core.windows.net/contenedor/img.jpg?sas_token...
      final uploadUrl = await _getUploadUrlFromBackend(fileName);

      // 2. Leer el archivo
      final fileBytes = await image.readAsBytes();

      // Intentar adivinar el tipo de contenido (opcional pero recomendado)
      final mimeType = lookupMimeType(image.path) ?? 'application/octet-stream';

      // 3. Subir a Azure Blob Storage usando la URL SAS
      final uri = Uri.parse(uploadUrl);

      final response = await httpClient.put(
        uri,
        headers: {
          'x-ms-blob-type': 'BlockBlob', // Requerido por Azure
          'Content-Type': mimeType,
        },
        body: fileBytes,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Retornamos la URL limpia (sin el token SAS) para guardarla en CosmosDB
        // El token SAS expira, así que guardamos la URL pública (si el contenedor es público)
        // o la referencia base.
        final cleanUrl = uri.origin + uri.path;
        return cleanUrl;
      } else {
        throw Exception(
          'Error subiendo a Azure (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Método auxiliar para pedir el permiso de escritura al backend
  Future<String> _getUploadUrlFromBackend(String fileName) async {
    // Asumimos que tienes un endpoint en tu Azure Function para esto
    // Ej: GET https://api.tudominio.com/api/getUploadUrl?filename=xyz.jpg
    final uri = Uri.parse(
      '${AzureConfig.apiBaseUrl}/getUploadUrl',
    ).replace(queryParameters: {'filename': fileName});

    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // El backend debe devolver { "url": "https://..." }
      return data['url'];
    } else {
      throw Exception(
        'No se pudo obtener la URL de carga: ${response.statusCode}',
      );
    }
  }
}
