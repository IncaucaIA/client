import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';

void main() {
  group('FilterDetail', () {
    final mockJson = {
      'id': '123',
      'image': {
        'url': 'http://example.com/image.png',
        'uploadedAt': '2024-05-04T10:00:00Z',
      },
      'aiResults': [
        {
          'impurityCount': 10,
          'metal': 2,
          'other': 3,
          'firstEffect': 1,
          'secondAndThirdEffect': 2,
          'fourthEffect': 1,
          'fifthEffect': 1,
          'quality': 80,
        }
      ],
    };

    final mockJsonAlternate = {
      'imageId': '456',
      'imageUrl': 'http://example.com/image2.png',
      'impurityDetection': {
        'totalParticles': 20,
        'quality': 90,
        'evaluatedAt': '2024-05-04T11:00:00Z',
        'impurities': [
          {'type': 'metal', 'count': 5},
          {'type': 'other', 'count': 15},
          {'type': 'secondAndThirdEffect', 'count': 10},
        ],
      },
    };

    test('should parse from standard JSON correctly', () {
      final detail = FilterDetail.fromJson(mockJson);

      expect(detail.id, '123');
      expect(detail.imageUrl, 'http://example.com/image.png');
      expect(detail.impurityCount, 10);
      expect(detail.metal, 2);
      expect(detail.other, 3);
      expect(detail.secondAndThirdEffect, 2);
      expect(detail.quality, 80);
      expect(detail.processedAt, DateTime.parse('2024-05-04T10:00:00Z'));
    });

    test('should parse from alternate JSON correctly', () {
      final detail = FilterDetail.fromJson(mockJsonAlternate);

      expect(detail.id, '456');
      expect(detail.imageUrl, 'http://example.com/image2.png');
      expect(detail.impurityCount, 20);
      expect(detail.metal, 5);
      expect(detail.other, 15);
      expect(detail.secondAndThirdEffect, 10);
      expect(detail.quality, 90);
      expect(detail.processedAt, DateTime.parse('2024-05-04T11:00:00Z'));
    });

    test('should support value equality', () {
      final detail1 = FilterDetail.fromJson(mockJson);
      final detail2 = FilterDetail.fromJson(mockJson);

      expect(detail1, equals(detail2));
    });
  });
}
