part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoadingMore extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoadingMore({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationSuccess extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool hasReachedMax;

  const NotificationSuccess({
    required this.notifications,
    required this.unreadCount,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasReachedMax];
}

class NotificationEmpty extends NotificationState {
  const NotificationEmpty();
}

class NotificationError extends NotificationState {
  final String message;
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationError({
    required this.message,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [message, notifications, unreadCount];
}
