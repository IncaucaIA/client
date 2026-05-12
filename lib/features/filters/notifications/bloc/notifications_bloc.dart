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
        final json = jsonDecode(data);
        // Backend sends the full DTO
        final detail = FilterDetail.fromJson(json);
        add(NotificationReceived(detail));
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
