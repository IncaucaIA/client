import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_summary.dart';

void main() {
  setUpAll(() {
    AppConfig.initialize();
  });

  group('FilterSummary', () {
    final mockJson = {
      'id': '1',
      'image': {
        'url': 'http://example.com/image.png',
        'uploadedAt': '2024-05-04T10:00:00Z',
      },
      'aiResults': [
        {'impurityCount': 5}
      ],
    };

    test('should parse from JSON correctly', () {
      final summary = FilterSummary.fromJson(mockJson);

      expect(summary.id, '1');
      expect(summary.imageUrl, 'http://example.com/image.png');
      expect(summary.impurityCount, 5);
      expect(summary.processedAt, DateTime.parse('2024-05-04T10:00:00Z'));
    });

    test('should use 0 for impurityCount if aiResults is missing or empty', () {
      final jsonNoAi = {
        'id': '2',
        'image': {
          'url': 'url2',
          'uploadedAt': '2024-05-04T10:00:00Z',
        },
      };
      final summary = FilterSummary.fromJson(jsonNoAi);
      expect(summary.impurityCount, 0);

      final jsonEmptyAi = {
        'id': '3',
        'image': {
          'url': 'url3',
          'uploadedAt': '2024-05-04T10:00:00Z',
        },
        'aiResults': [],
      };
      final summaryEmpty = FilterSummary.fromJson(jsonEmptyAi);
      expect(summaryEmpty.impurityCount, 0);
    });

    test('should support value equality', () {
      final summary1 = FilterSummary.fromJson(mockJson);
      final summary2 = FilterSummary.fromJson(mockJson);

      expect(summary1, equals(summary2));
    });
  });
}
