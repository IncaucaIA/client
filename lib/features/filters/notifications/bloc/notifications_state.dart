import 'package:equatable/equatable.dart';
import '../../domain/models/filter_detail.dart';

class NotificationsState extends Equatable {
  final List<FilterDetail> notifications;

  const NotificationsState({
    this.notifications = const [],
  });

  NotificationsState copyWith({
    List<FilterDetail>? notifications,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [notifications];
}
