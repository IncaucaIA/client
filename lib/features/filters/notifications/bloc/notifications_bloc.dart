import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/filter_repository.dart';
import '../../domain/models/filter_detail.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final FilterRepository _filterRepository;
  StreamSubscription? _subscription;

  NotificationsBloc({
    required FilterRepository filterRepository,
  })  : _filterRepository = filterRepository,
        super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationReceived>(_onReceived);
    on<NotificationsCleared>(_onCleared);
  }

  void _onStarted(NotificationsStarted event, Emitter<NotificationsState> emit) {
    _subscription?.cancel();
    _subscription = _filterRepository.listenToNotifications().listen((data) {
      try {
        var decoded = jsonDecode(data);
        if (decoded is String) {
          try { decoded = jsonDecode(decoded); } catch (_) {}
        }

        dynamic recordData = decoded;
        
        // Extraer recursivamente si el mensaje viene envuelto en múltiples capas de 'data'
        while (recordData is Map<String, dynamic> && recordData.containsKey('data')) {
          var innerData = recordData['data'];
          if (innerData is String) {
            try { innerData = jsonDecode(innerData); } catch (_) {}
          }
          recordData = innerData;
        }

        if (recordData is Map<String, dynamic>) {
          // Verificamos que contenga claves típicas de nuestro modelo para evitar procesar mensajes de control
          if (recordData.containsKey('id') || recordData.containsKey('imageId') || recordData.containsKey('aiResults') || recordData.containsKey('image')) {
            final detail = FilterDetail.fromJson(recordData);
            add(NotificationReceived(detail));
            print('✅ Notification successfully parsed and added: ${detail.id}');
          } else {
            print('⚠️ El mensaje no parece un registro de filtro: $recordData');
          }
        } else {
          print('⚠️ No se pudo extraer un Map válido del mensaje. Tipo final: ${recordData.runtimeType}');
        }
      } catch (e) {
        print('❌ Error parsing notification: $e');
      }
    });
  }

  void _onReceived(NotificationReceived event, Emitter<NotificationsState> emit) {
    final updatedList = List<FilterDetail>.from(state.notifications)
      ..insert(0, event.detail);
    emit(state.copyWith(notifications: updatedList));
  }

  void _onCleared(NotificationsCleared event, Emitter<NotificationsState> emit) {
    emit(const NotificationsState());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
