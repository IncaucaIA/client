import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadImageRequested extends UploadEvent {
  final File image;
  final String userId;
  final List<String> tags;

  const UploadImageRequested({
    required this.image,
    required this.userId,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [image, userId, tags];
}

class WebSocketConnectionRequested extends UploadEvent {
  const WebSocketConnectionRequested();
}

class NotificationReceived extends UploadEvent {
  final String message;

  const NotificationReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class WebSocketDisconnectionRequested extends UploadEvent {
  const WebSocketDisconnectionRequested();
}
