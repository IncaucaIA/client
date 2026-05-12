import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/core/config_strategy.dart';

void main() {
  group('CloudConfigStrategy', () {
    late CloudConfigStrategy strategy;

    setUp(() {
      strategy = CloudConfigStrategy();
    });

    test('should return correct defaults for cloud', () {
      expect(strategy.apiBaseUrl, 'https://incauca-linux-function-app.azurewebsites.net/api');
      expect(strategy.negotiateEndpoint, '/negotiate');
      expect(strategy.getUploadUrlEndpoint, '/generate_upload_urls');
      expect(strategy.wsEndpoint, isNull);
      expect(strategy.uploadEndpoint, isNull);
      expect(strategy.isCloud, isTrue);
    });
  });

  group('LocalConfigStrategy', () {
    late LocalConfigStrategy strategy;

    setUp(() {
      strategy = LocalConfigStrategy();
    });

    test('should return correct defaults for local', () {
      // It defaults to 10.147.17.100:8000 based on the default value in the file
      expect(strategy.apiBaseUrl, 'http://10.147.17.100:8000/api');
      expect(strategy.negotiateEndpoint, isNull);
      expect(strategy.getUploadUrlEndpoint, isNull);
      expect(strategy.wsEndpoint, 'ws://10.147.17.100:8000/ws/results');
      expect(strategy.uploadEndpoint, '/analysis/upload');
      expect(strategy.isCloud, isFalse);
    });

    test('should handle buildUrl edge cases', () {
      // Test url.contains('://')
      expect(strategy.buildUrl('https://example.com', 'http', '/api'), 'http://example.com/api');
      
      // Test url.endsWith('/')
      expect(strategy.buildUrl('example.com/', 'http', '/api'), 'http://example.com/api');
      
      // Test urlLower.endsWith(pathLower)
      expect(strategy.buildUrl('example.com/api', 'http', '/api'), 'http://example.com/api');
      
      // Test urlLower.contains('$pathLower/')
      expect(strategy.buildUrl('example.com/api/test', 'http', '/api'), 'http://example.com/api/test');
    });

    test('should handle wsEndpoint edge cases with /api suffix', () {
      final strategy1 = LocalConfigStrategy(baseUrl: 'example.com/api');
      expect(strategy1.wsEndpoint, 'ws://example.com/ws/results');

      final strategy2 = LocalConfigStrategy(baseUrl: 'example.com/api/');
      expect(strategy2.wsEndpoint, 'ws://example.com/ws/results');
    });

    test('should handle uploadEndpoint edge cases', () {
      final strategy1 = LocalConfigStrategy(uploadEndpoint: 'custom/upload');
      expect(strategy1.uploadEndpoint, '/custom/upload');
    });
  });
}
