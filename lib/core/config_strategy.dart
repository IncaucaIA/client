import 'package:flutter/foundation.dart';

abstract class ConfigStrategy {
  String get apiBaseUrl;
  String? get negotiateEndpoint;
  String? get getUploadUrlEndpoint;
  String? get wsEndpoint;
  String? get uploadEndpoint;
  bool get isCloud;
}

class CloudConfigStrategy implements ConfigStrategy {
  @override
  String get apiBaseUrl => const String.fromEnvironment(
        'AZURE_API_BASE_URL',
        defaultValue: 'https://incauca-linux-function-app.azurewebsites.net/api',
      );

  @override
  String get negotiateEndpoint => const String.fromEnvironment(
        'AZURE_NEGOTIATE_ENDPOINT',
        defaultValue: '/negotiate',
      );

  @override
  String get getUploadUrlEndpoint => const String.fromEnvironment(
        'AZURE_GENERATE_UPLOAD_URL_ENDPOINT',
        defaultValue: '/generate_upload_urls',
      );

  @override
  String? get wsEndpoint => null;

  @override
  String? get uploadEndpoint => null;

  @override
  bool get isCloud => true;

}

class LocalConfigStrategy implements ConfigStrategy {
  static const String _defaultBaseUrl = '10.147.17.100:8000';
  final String _baseUrl;
  final String _uploadEndpointStr;

  LocalConfigStrategy({String? baseUrl, String? uploadEndpoint})
      : _baseUrl = baseUrl ?? const String.fromEnvironment('LOCAL_BASE_URL', defaultValue: _defaultBaseUrl),
        _uploadEndpointStr = uploadEndpoint ?? const String.fromEnvironment('LOCAL_UPLOAD_ENDPOINT', defaultValue: '/analysis/upload');

  @visibleForTesting
  String buildUrl(String baseUrl, String defaultScheme, String defaultPath) {
    var url = baseUrl.trim();
    if (url.isEmpty) url = _defaultBaseUrl;

    // Check if it already has a scheme (http://, https://, ws://, etc)
    if (url.contains('://')) {
      // Replace existing scheme with the requested one
      url = '$defaultScheme://${url.split('://')[1]}';
    } else {
      url = '$defaultScheme://$url';
    }

    // Remove trailing slash to avoid double slashes when joining
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    // Check if it already contains the specific path suffix (case-insensitive check)
    final urlLower = url.toLowerCase();
    final pathLower = defaultPath.toLowerCase();
    
    if (!urlLower.endsWith(pathLower) && !urlLower.contains('$pathLower/')) {
      url = '$url$defaultPath';
    }

    return url;
  }

  @override
  String get apiBaseUrl {
    return buildUrl(_baseUrl, 'http', '/api');
  }

  @override
  String? get negotiateEndpoint => null;

  @override
  String? get getUploadUrlEndpoint => null;

  @override
  String get wsEndpoint {
    var baseUrl = _baseUrl.trim();

    // Strip /api if it exists to allow ws://host/ws/results instead of ws://host/api/ws/results
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    } else if (baseUrl.endsWith('/api/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 5);
    }

    return buildUrl(baseUrl, 'ws', '/ws/results');
  }

  @override
  String get uploadEndpoint {
    return _uploadEndpointStr.startsWith('/') ? _uploadEndpointStr : '/$_uploadEndpointStr';
  }

  @override
  bool get isCloud => false;
}
