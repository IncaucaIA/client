import 'package:equatable/equatable.dart';
import '../../domain/models/filter_detail.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsStarted extends NotificationsEvent {}

class NotificationReceived extends NotificationsEvent {
  final FilterDetail detail;
  const NotificationReceived(this.detail);

  @override
  List<Object?> get props => [detail];
}

class NotificationsCleared extends NotificationsEvent {}
