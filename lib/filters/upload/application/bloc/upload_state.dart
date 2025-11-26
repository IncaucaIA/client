import 'package:equatable/equatable.dart';
import '../../domain/models/image_document.dart';

abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

class UploadInitial extends UploadState {
  const UploadInitial();
}

class UploadInProgress extends UploadState {
  const UploadInProgress();
}

class UploadSuccess extends UploadState {
  final ImageDocument document;

  const UploadSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class UploadFailure extends UploadState {
  final String error;

  const UploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class WebSocketConnected extends UploadState {
  const WebSocketConnected();
}

class WebSocketDisconnected extends UploadState {
  const WebSocketDisconnected();
}

class NotificationReceivedState extends UploadState {
  final String message;
  final DateTime timestamp;

  const NotificationReceivedState({
    required this.message,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [message, timestamp];
}
