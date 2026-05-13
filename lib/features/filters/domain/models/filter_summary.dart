import 'package:equatable/equatable.dart';
import 'package:incauca_labs/core/config.dart';

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
      imageUrl: _fixLocalUrl(imageObj['url']?.toString() ?? ''),
      impurityCount: impurityCount,
      processedAt: DateTime.tryParse(imageObj['uploadedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static String _fixLocalUrl(String url) {
    // Solo aplicar en entorno local
    if (AppConfig.isCloud) return url;
    if (url.isEmpty) return url;

    try {
      final uri = Uri.parse(url);
      // Reemplazar localhost/127.0.0.1 por el host configurado en LOCAL_BASE_URL
      if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        final baseUri = Uri.parse(AppConfig.apiBaseUrl);
        return uri.replace(
          host: baseUri.host,
          port: baseUri.port,
        ).toString();
      }
    } catch (_) {}
    return url;
  }

  @override
  List<Object?> get props => [id, imageUrl, impurityCount, processedAt];
}
