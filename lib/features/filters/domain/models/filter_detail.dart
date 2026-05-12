import 'package:equatable/equatable.dart';

class FilterDetail extends Equatable {
  final String id;
  final String imageUrl;
  final int impurityCount;
  final int metal;
  final int other;
  final int firstEffect;
  final int secondAndThirdEffect;
  final int fourthEffect;
  final int fifthEffect;
  final int quality;
  final DateTime processedAt;

  const FilterDetail({
    required this.id,
    required this.imageUrl,
    required this.impurityCount,
    required this.metal,
    required this.other,
    required this.firstEffect,
    required this.secondAndThirdEffect,
    required this.fourthEffect,
    required this.fifthEffect,
    required this.quality,
    required this.processedAt,
  });

  factory FilterDetail.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('impurityDetection')) {
      final impurityDetection = json['impurityDetection'] as Map<String, dynamic>? ?? {};
      final impurities = impurityDetection['impurities'] as List<dynamic>? ?? [];

      int getCount(String type) {
        final item = impurities.firstWhere(
          (e) => (e as Map)['type'] == type, 
          orElse: () => {'count': 0}
        );
        return (item['count'] as num?)?.toInt() ?? 0;
      }

      return FilterDetail(
        id: json['imageId']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString() ?? '',
        impurityCount: (impurityDetection['totalParticles'] as num?)?.toInt() ?? 0,
        metal: getCount('metal'),
        other: getCount('other'),
        firstEffect: getCount('firstEffect'),
        secondAndThirdEffect: getCount('secondAndThirdEffect'),
        fourthEffect: getCount('fourthEffect'),
        fifthEffect: getCount('fifthEffect'),
        quality: (impurityDetection['quality'] as num?)?.toInt() ?? 0,
        processedAt: DateTime.tryParse(impurityDetection['evaluatedAt']?.toString() ?? '') ?? DateTime.now(),
      );
    }

    final imageObj = json['image'] ?? {};
    final aiList = json['aiResults'] as List? ?? [];
    final aiData = aiList.isNotEmpty ? aiList[0] : {};

    return FilterDetail(
      id: json['id']?.toString() ?? '',
      imageUrl: imageObj['url']?.toString() ?? '',
      impurityCount: (aiData['impurityCount'] as num?)?.toInt() ?? 0,
      metal: (aiData['metal'] as num?)?.toInt() ?? 0,
      other: (aiData['other'] as num?)?.toInt() ?? 0,
      firstEffect: (aiData['firstEffect'] as num?)?.toInt() ?? 0,
      secondAndThirdEffect: (aiData['secondAndThirdEffect'] as num?)?.toInt() ?? 0,
      fourthEffect: (aiData['fourthEffect'] as num?)?.toInt() ?? 0,
      fifthEffect: (aiData['fifthEffect'] as num?)?.toInt() ?? 0,
      quality: (aiData['quality'] as num?)?.toInt() ?? 0,
      processedAt: DateTime.tryParse(imageObj['uploadedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        impurityCount,
        metal,
        other,
        firstEffect,
        secondAndThirdEffect,
        fourthEffect,
        fifthEffect,
        quality,
        processedAt,
      ];
}
