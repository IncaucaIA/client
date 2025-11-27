import 'package:equatable/equatable.dart';
import 'package:incauca_labs/filters/upload/domain/models/analysis_result.dart';
import '../../domain/models/image_document.dart';

enum UploadStatus { initial, loading, success, failure }

class UploadState extends Equatable {
  final UploadStatus uploadStatus;
  final bool isConnected; // Esta propiedad persistirá entre eventos
  final ImageDocument? document;
  final String? errorMessage;
  final AnalysisResult? lastAnalysisResult; 
  final DateTime? lastNotificationTime;

  const UploadState({
    this.uploadStatus = UploadStatus.initial,
    this.isConnected = false,
    this.document,
    this.errorMessage,
    this.lastAnalysisResult,
    this.lastNotificationTime,
  });

  // Método copyWith para actualizar solo lo que cambia
  UploadState copyWith({
    UploadStatus? uploadStatus,
    bool? isConnected,
    ImageDocument? document,
    String? errorMessage,
    AnalysisResult? lastAnalysisResult,
    DateTime? lastNotificationTime,
  }) {
    return UploadState(
      uploadStatus: uploadStatus ?? this.uploadStatus,
      isConnected: isConnected ?? this.isConnected,
      document: document ?? this.document,
      errorMessage: errorMessage ?? this.errorMessage,
      lastAnalysisResult: lastAnalysisResult ?? this.lastAnalysisResult,
      lastNotificationTime: lastNotificationTime ?? this.lastNotificationTime,
    );
  }

  @override
  List<Object?> get props => [
        uploadStatus,
        isConnected,
        document,
        errorMessage,
        lastAnalysisResult,
        lastNotificationTime,
      ];
}