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
    return FilterSummary(
      id: json['id'].toString(),
      imageUrl: json['image']['url'] as String,
      impurityCount: impurityCount,
      processedAt: DateTime.parse(json['image']['uploadedAt']),
    );
  }

  @override
  List<Object?> get props => [id, imageUrl, impurityCount, processedAt];
}
