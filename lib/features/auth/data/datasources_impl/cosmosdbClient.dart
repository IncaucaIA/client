import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class CosmosDBClient {
  final String endpoint;
  final String databaseId;
  final String containerId;
  final String masterKey;

  CosmosDBClient({
    required this.endpoint,
    required this.databaseId,
    required this.containerId,
    required this.masterKey,
  });

  Future<Map<String, dynamic>?> getDocument(String docId) async {
    final String resourceType = 'docs';
    final String resourceId = 'dbs/$databaseId/colls/$containerId/docs/$docId';

    final date = HttpDate.format(DateTime.now().toUtc());

    final authHeader = buildAuthHeader(
      verb: 'GET',
      resourceType: resourceType,
      resourceId: resourceId,
      date: date,
      masterKey: masterKey,
    );

    final url =
        Uri.parse('$endpoint/dbs/$databaseId/colls/$containerId/docs/$docId');

    final res = await http.get(url, headers: {
      'Authorization': authHeader,
      'x-ms-date': date,
      'x-ms-version': '2018-12-31',
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    if (res.statusCode == 404) return null;

    throw Exception('Cosmos error ${res.statusCode}: ${res.body}');
  }

  Future<void> upsertDocument(String id, Map<String, dynamic> data) async {
    final String resourceType = 'docs';
    final String resourceId = 'dbs/$databaseId/colls/$containerId';

    final date = HttpDate.format(DateTime.now().toUtc());

    final authHeader = buildAuthHeader(
      verb: 'POST',
      resourceType: resourceType,
      resourceId: resourceId,
      date: date,
      masterKey: masterKey,
    );

    final url =
        Uri.parse('$endpoint/dbs/$databaseId/colls/$containerId/docs');

    final body = jsonEncode({
      'id': id,
      ...data,
    });

    final res = await http.post(url, headers: {
      'Authorization': authHeader,
      'x-ms-date': date,
      'x-ms-version': '2018-12-31',
      'Content-Type': 'application/json',
    }, body: body);

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Cosmos error ${res.statusCode}: ${res.body}');
    }
  }
}


String buildAuthHeader({
  required String verb,
  required String resourceType,
  required String resourceId,
  required String date,
  required String masterKey,
}) {
  final key = base64Decode(masterKey);
  final payload = utf8.encode(
    '${verb.toLowerCase()}\n'
    '${resourceType.toLowerCase()}\n'
    '$resourceId\n'
    '${date.toLowerCase()}\n'
    '\n'
  );

  final hmac = Hmac(sha256, key);
  final signature = hmac.convert(payload);
  final base64Signature = base64Encode(signature.bytes);

  final authString =
      'type=master&ver=1.0&sig=$base64Signature';

  return Uri.encodeComponent(authString);
}
