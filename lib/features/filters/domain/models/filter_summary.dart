import 'package:equatable/equatable.dart';

class FilterSummary extends Equatable {
  final String id;
  final String imageUrl;
  final int impurityCount;
  final DateTime processedAt;

  const FilterSummary({
    required this.id,
    required this.imageUrl,
    required this.impurityCount,
    required this.processedAt,
  });

  factory FilterSummary.fromJson(Map<String, dynamic> json) {
    int impurityCount = 0;
    if (json['aiResults'] != null && (json['aiResults'] as List).isNotEmpty) {
      impurityCount = json['aiResults'][0]['impurityCount'] as int;
    }
    final imageObj = json['image'] as Map<String, dynamic>? ?? {};
    return FilterSummary(
      id: json['id'].toString(),
      imageUrl: imageObj['url']?.toString() ?? '',
      impurityCount: impurityCount,
      processedAt: DateTime.tryParse(imageObj['uploadedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, imageUrl, impurityCount, processedAt];
}
