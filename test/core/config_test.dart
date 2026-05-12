import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/core/config_strategy.dart';

void main() {
  group('AppConfig', () {
    setUpAll(() {
      AppConfig.initialize();
    });

    test('should return correct properties from initialized strategy', () {
      expect(AppConfig.strategy, isA<ConfigStrategy>());
      
      // We just call the getters to ensure they execute and delegate to the strategy correctly
      // The exact return values depend on the environment it was initialized in (default is local)
      
      expect(AppConfig.apiBaseUrl, AppConfig.strategy.apiBaseUrl);
      expect(AppConfig.isCloud, AppConfig.strategy.isCloud);
      expect(AppConfig.negotiateEndpoint, AppConfig.strategy.negotiateEndpoint);
      expect(AppConfig.getUploadUrlEndpoint, AppConfig.strategy.getUploadUrlEndpoint);
      expect(AppConfig.wsEndpoint, AppConfig.strategy.wsEndpoint);
      expect(AppConfig.uploadEndpoint, AppConfig.strategy.uploadEndpoint);
      
      // Instantiate to cover class declaration
      final instance = AppConfig();
      expect(instance, isNotNull);
    });

    test('should initialize CloudConfigStrategy when environment is cloud', () {
      AppConfig.setEnvironmentForTesting('cloud');
      AppConfig.initialize();
      expect(AppConfig.strategy, isA<CloudConfigStrategy>());
      expect(AppConfig.isCloud, isTrue);
      
      // Restore default
      AppConfig.setEnvironmentForTesting('local');
      AppConfig.initialize();
    });
  });
}
