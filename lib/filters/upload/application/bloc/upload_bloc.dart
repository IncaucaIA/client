import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/filter_repository.dart';
import 'upload_event.dart';
import 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final FilterRepository repository;
  StreamSubscription<String>? _notificationSubscription;

  UploadBloc({required this.repository}) : super(const UploadInitial()) {
    on<UploadImageRequested>(_onUploadImageRequested);
    on<WebSocketConnectionRequested>(_onWebSocketConnectionRequested);
    on<NotificationReceived>(_onNotificationReceived);
    on<WebSocketDisconnectionRequested>(_onWebSocketDisconnectionRequested);
  }

  Future<void> _onUploadImageRequested(
    UploadImageRequested event,
    Emitter<UploadState> emit,
  ) async {
    emit(const UploadInProgress());
    try {
      final document = await repository.uploadImageWithMetadata(
        image: event.image,
        userId: event.userId,
        tags: event.tags,
      );
      emit(UploadSuccess(document));
    } catch (e) {
      emit(UploadFailure(e.toString()));
    }
  }

  Future<void> _onWebSocketConnectionRequested(
    WebSocketConnectionRequested event,
    Emitter<UploadState> emit,
  ) async {
    try {
      await repository.connectToNotifications();
      emit(const WebSocketConnected());

      // Subscribe to notification stream
      _notificationSubscription = repository.listenToNotifications().listen(
        (message) {
          add(NotificationReceived(message));
        },
      );
    } catch (e) {
      emit(UploadFailure('Failed to connect to WebSocket: $e'));
    }
  }

  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<UploadState> emit,
  ) async {
    emit(NotificationReceivedState(
      message: event.message,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _onWebSocketDisconnectionRequested(
    WebSocketDisconnectionRequested event,
    Emitter<UploadState> emit,
  ) async {
    await _notificationSubscription?.cancel();
    await repository.disconnectFromNotifications();
    emit(const WebSocketDisconnected());
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
