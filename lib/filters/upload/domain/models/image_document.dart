import 'package:equatable/equatable.dart';
import 'ai_result.dart';

class ImageDocument extends Equatable {
  final String id;
  final ImageInfo image;
  final List<AIResult> aiResults;
  final ImageMetadata metadata;

  const ImageDocument({
    required this.id,
    required this.image,
    required this.aiResults,
    required this.metadata,
  });

  factory ImageDocument.fromJson(Map<String, dynamic> json) {
    return ImageDocument(
      id: json['id'] as String,
      image: ImageInfo.fromJson(json['image'] as Map<String, dynamic>),
      aiResults: (json['aiResults'] as List)
          .map((e) => AIResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata:
          ImageMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image.toJson(),
      'aiResults': aiResults.map((e) => e.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, image, aiResults, metadata];
}

class ImageInfo extends Equatable {
  final String url;
  final String uploadedAt;

  const ImageInfo({
    required this.url,
    required this.uploadedAt,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      url: json['url'] as String,
      uploadedAt: json['uploadedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'uploadedAt': uploadedAt,
    };
  }

  @override
  List<Object?> get props => [url, uploadedAt];
}

class ImageMetadata extends Equatable {
  final String userId;
  final List<String> tags;

  const ImageMetadata({
    required this.userId,
    required this.tags,
  });

  factory ImageMetadata.fromJson(Map<String, dynamic> json) {
    return ImageMetadata(
      userId: json['userId'] as String,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tags': tags,
    };
  }

  @override
  List<Object?> get props => [userId, tags];
}
