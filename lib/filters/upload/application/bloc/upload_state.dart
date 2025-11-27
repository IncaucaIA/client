import 'package:equatable/equatable.dart';
import '../../domain/models/image_document.dart';

enum UploadStatus { initial, loading, success, failure }

class UploadState extends Equatable {
  final UploadStatus uploadStatus;
  final bool isConnected; // Esta propiedad persistirá entre eventos
  final ImageDocument? document;
  final String? errorMessage;
  final String? lastNotificationMessage; // Para disparar el SnackBar
  final DateTime? lastNotificationTime;

  const UploadState({
    this.uploadStatus = UploadStatus.initial,
    this.isConnected = false,
    this.document,
    this.errorMessage,
    this.lastNotificationMessage,
    this.lastNotificationTime,
  });

  // Método copyWith para actualizar solo lo que cambia
  UploadState copyWith({
    UploadStatus? uploadStatus,
    bool? isConnected,
    ImageDocument? document,
    String? errorMessage,
    String? lastNotificationMessage,
    DateTime? lastNotificationTime,
  }) {
    return UploadState(
      uploadStatus: uploadStatus ?? this.uploadStatus,
      isConnected: isConnected ?? this.isConnected,
      document: document ?? this.document,
      errorMessage: errorMessage ?? this.errorMessage,
      lastNotificationMessage: lastNotificationMessage ?? this.lastNotificationMessage,
      lastNotificationTime: lastNotificationTime ?? this.lastNotificationTime,
    );
  }

  @override
  List<Object?> get props => [
        uploadStatus,
        isConnected,
        document,
        errorMessage,
        lastNotificationMessage,
        lastNotificationTime,
      ];
}