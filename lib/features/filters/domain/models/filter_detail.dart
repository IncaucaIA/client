import 'package:equatable/equatable.dart';

class FilterDetail extends Equatable {
  final String id;
  final String imageUrl;
  final int impurityCount;
  final int fineBagasse;
  final int metal;
  final int sand;
  final int firstEffect;
  final int secondEffect;
  final int thirdEffect;
  final int fourthEffect;
  final int fifthEffect;
  final DateTime processedAt;

  const FilterDetail({
    required this.id,
    required this.imageUrl,
    required this.impurityCount,
    required this.fineBagasse,
    required this.metal,
    required this.sand,
    required this.firstEffect,
    required this.secondEffect,
    required this.thirdEffect,
    required this.fourthEffect,
    required this.fifthEffect,
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
        fineBagasse: getCount('fineBagasse'),
        metal: getCount('metal'),
        sand: getCount('sand'),
        firstEffect: getCount('firstEffect'),
        secondEffect: getCount('secondEffect'),
        thirdEffect: getCount('thirdEffect'),
        fourthEffect: getCount('fourthEffect'),
        fifthEffect: getCount('fifthEffect'),
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
      fineBagasse: (aiData['fineBagasse'] as num?)?.toInt() ?? 0,
      metal: (aiData['metal'] as num?)?.toInt() ?? 0,
      sand: (aiData['sand'] as num?)?.toInt() ?? 0,
      firstEffect: (aiData['firstEffect'] as num?)?.toInt() ?? 0,
      secondEffect: (aiData['secondEffect'] as num?)?.toInt() ?? 0,
      thirdEffect: (aiData['thirdEffect'] as num?)?.toInt() ?? 0,
      fourthEffect: (aiData['fourthEffect'] as num?)?.toInt() ?? 0,
      fifthEffect: (aiData['fifthEffect'] as num?)?.toInt() ?? 0,
      processedAt: DateTime.tryParse(imageObj['uploadedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, impurityCount, fineBagasse];
}
