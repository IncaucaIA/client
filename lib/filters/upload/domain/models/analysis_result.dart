import 'package:equatable/equatable.dart';

class AnalysisResult extends Equatable {
  final String id;
  final String imageUrl;
  final int impurityCount;
  final int fineBagasse;
  final int metal;
  final int sand;
  // Efectos (pueden ser bool, int o double dependiendo de tu lógica, asumo double o int)
  final int firstEffect;
  final int secondEffect;
  final int thirdEffect;
  final int fourthEffect;
  final int fifthEffect;
  final DateTime processedAt;

  const AnalysisResult({
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

  // Factory para convertir el JSON feo en este objeto bonito
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {

    final imageObj = json['image'] ?? {};
    final aiList = json['aiResults'] as List? ?? [];
    final aiData = aiList.isNotEmpty ? aiList[0] : {};

    return AnalysisResult(
      id: json['id'] ?? '',
      imageUrl: imageObj['url'] ?? '',
      // Manejo seguro de nulos y tipos numéricos
      impurityCount: (aiData['impurityCount'] as num?)?.toInt() ?? 0,
      fineBagasse: (aiData['fineBagasse'] as num?)?.toInt() ?? 0,
      metal: (aiData['metal'] as num?)?.toInt() ?? 0,
      sand: (aiData['sand'] as num?)?.toInt() ?? 0,
      firstEffect: (aiData['firstEffect'] as num?)?.toInt() ?? 0,
      secondEffect: (aiData['secondEffect'] as num?)?.toInt() ?? 0,
      thirdEffect: (aiData['thirdEffect'] as num?)?.toInt() ?? 0,
      fourthEffect: (aiData['fourthEffect'] as num?)?.toInt() ?? 0,
      fifthEffect: (aiData['fifthEffect'] as num?)?.toInt() ?? 0,
      processedAt: DateTime.tryParse(imageObj['uploadedAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, impurityCount, fineBagasse];
}