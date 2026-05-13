import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/features/auth/data/local_auth_datasource_impl.dart';

import '../domain/filter_repository.dart';
import '../domain/models/filter_detail.dart';
import '../domain/models/filter_summary.dart';
import '../domain/models/paginated_result.dart';
import 'package:incauca_labs/features/filters/domain/websocket_datasource.dart';

class FilterRepositoryImpl implements FilterRepository {
  final WebSocketDatasource webSocketDataSource;
  final http.Client _httpClient;
  final Future<String?> Function()? tokenProvider;

  FilterRepositoryImpl({
    required this.webSocketDataSource,
    http.Client? httpClient,
    this.tokenProvider,
  }) : _httpClient = httpClient ?? http.Client();

  Future<String?> _getToken() async {
    if (tokenProvider != null) {
      return await tokenProvider!();
    }
    if (AppConfig.isCloud) {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } else {
      return await LocalAuthDatasourceImpl.getToken();
    }
  }

  @override
  Future<PaginatedResult<FilterDetail>> getFilters({
    int limit = 10,
    int offset = 0,
    String? startDate,
    String? endDate,
  }) async {
    final token = await _getToken();
    final baseUrl = AppConfig.apiBaseUrl;

    final queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };

    final uri = Uri.parse('$baseUrl/records').replace(queryParameters: queryParams);

    final response = await _httpClient.get(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PaginatedResult<FilterDetail>.fromJson(
        json,
        (item) => FilterDetail.fromJson(item),
      );
    } else {
      throw Exception('Failed to fetch records: ${response.body}');
    }
  }

  @override
  Stream<PaginatedResult<FilterDetail>> watchFilters({
    int limit = 10,
    int offset = 0,
    String? startDate,
    String? endDate,
  }) async* {
    // 1. Emit initial data
    yield await getFilters(
      limit: limit,
      offset: offset,
      startDate: startDate,
      endDate: endDate,
    );

    // 2. Listen to notifications and yield updated data whenever a new message arrives
    await for (final _ in listenToNotifications()) {
      yield await getFilters(
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
      );
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
