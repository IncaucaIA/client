import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/filters/upload/domain/cosmos_db_remote_datasource.dart';
import 'package:incauca_labs/filters/upload/domain/models/image_document.dart';

class CosmosDbRemoteDatasourceImpl implements CosmosDbRemoteDatasource {
  final http.Client httpClient;

  CosmosDbRemoteDatasourceImpl({required this.httpClient});

  @override
  Future<ImageDocument> createDocument(ImageDocument document) async {
    try {
      final url = Uri.parse(
        '${AzureConfig.cosmosDbEndpoint}dbs/${AzureConfig.databaseName}/colls/${AzureConfig.containerName}/docs',
      );

      final now = DateTime.now().toUtc();
      final dateString = _formatHttpDate(now);

      // Create authorization token
      final authToken = _generateAuthToken(
        verb: 'POST',
        resourceType: 'docs',
        resourceLink:
            'dbs/${AzureConfig.databaseName}/colls/${AzureConfig.containerName}',
        date: dateString,
      );

      final response = await httpClient.post(
        url,
        headers: {
          'Authorization': authToken,
          'x-ms-date': dateString,
          'x-ms-version': '2018-12-31',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(document.toJson()),
      );

      if (response.statusCode == 201) {
        return ImageDocument.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to create document: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to create Cosmos DB document: $e');
    }
  }

  String _generateAuthToken({
    required String verb,
    required String resourceType,
    required String resourceLink,
    required String date,
  }) {
    final key = AzureConfig.cosmosDbKey;
    final payload =
        '${verb.toLowerCase()}\n${resourceType.toLowerCase()}\n$resourceLink\n${date.toLowerCase()}\n\n';

    final keyBytes = base64Decode(key);
    final hmac = Hmac(sha256, keyBytes);
    final signature = hmac.convert(utf8.encode(payload));
    final encodedSignature = base64Encode(signature.bytes);

    return Uri.encodeComponent('type=master&ver=1.0&sig=$encodedSignature');
  }

  String _formatHttpDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');

    return '$weekday, $day $month $year $hour:$minute:$second GMT';
  }
}
