import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/filter_repository.dart';
import 'upload_event.dart';
import 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final FilterRepository repository;
  StreamSubscription<String>? _notificationSubscription;

  UploadBloc({required this.repository}) : super(const UploadState()) {
    on<UploadImageRequested>(_onUploadImageRequested);
    on<WebSocketConnectionRequested>(_onWebSocketConnectionRequested);
    on<NotificationReceived>(_onNotificationReceived);
    on<WebSocketDisconnectionRequested>(_onWebSocketDisconnectionRequested);
  }


  Future<void> _onUploadImageRequested(
    UploadImageRequested event,
    Emitter<UploadState> emit,
  ) async {
    // Mantenemos isConnected igual, solo cambiamos el status a loading
    emit(state.copyWith(uploadStatus: UploadStatus.loading));
    try {
      final document = await repository.uploadImageWithMetadata(
        image: event.image,
        userId: event.userId,
        tags: event.tags,
      );
      emit(state.copyWith(
        uploadStatus: UploadStatus.success,
        document: document,
      ));
    } catch (e) {
      emit(state.copyWith(
        uploadStatus: UploadStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }


  Future<void> _onWebSocketConnectionRequested(
    WebSocketConnectionRequested event,
    Emitter<UploadState> emit,
  ) async {
    try {
      await repository.connectToNotifications();
      // Marcamos como conectado
      emit(state.copyWith(isConnected: true));

      _notificationSubscription = repository.listenToNotifications().listen(
        (message) {
          add(NotificationReceived(message));
        },
      );
    } catch (e) {
      // Si falla la conexión, marcamos error pero no cambiamos el uploadStatus si no es necesario
      emit(state.copyWith(
        isConnected: false,
        errorMessage: 'Failed to connect to WebSocket: $e',
      ));
    }
  }

  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<UploadState> emit,
  ) async {
    // AQUÍ ESTÁ LA MAGIA: 
    // Usamos copyWith, por lo que isConnected sigue siendo true del estado anterior
    emit(state.copyWith(
      lastNotificationMessage: event.message,
      lastNotificationTime: DateTime.now(),
    ));
  }

  Future<void> _onWebSocketDisconnectionRequested(
    WebSocketDisconnectionRequested event,
    Emitter<UploadState> emit,
  ) async {
    await _notificationSubscription?.cancel();
    await repository.disconnectFromNotifications();
    emit(state.copyWith(isConnected: false));
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
