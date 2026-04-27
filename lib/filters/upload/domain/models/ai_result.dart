import 'package:equatable/equatable.dart';

class AIResult extends Equatable {
  final String model;
  final String prediction;
  final double confidence;

  const AIResult({
    required this.model,
    required this.prediction,
    required this.confidence,
  });

  factory AIResult.fromJson(Map<String, dynamic> json) {
    return AIResult(
      model: json['model'] as String,
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'prediction': prediction,
      'confidence': confidence,
    };
  }

  @override
  List<Object?> get props => [model, prediction, confidence];
}
