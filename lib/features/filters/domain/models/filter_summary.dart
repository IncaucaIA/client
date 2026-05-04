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

  @override
  List<Object?> get props => [id, imageUrl, impurityCount, processedAt];
}
