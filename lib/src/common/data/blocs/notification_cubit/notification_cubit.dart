import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required NotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(NotificationInitial());

  final NotificationRepository _notificationRepository;
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;
  DocumentSnapshot? _lastDocument;
  String? _currentUserId;

  /// Initialize notifications for a user
  Future<void> initialize(String userId) async {
    if (_currentUserId == userId && state is! NotificationInitial) {
      return; // Already initialized for this user
    }

    _currentUserId = userId;
    await _cancelSubscription();

    emit(NotificationLoading());

    try {
      // Start streaming notifications
      _startNotificationStream(userId);

      // Get initial unread count
      await _updateUnreadCount(userId);
    } catch (error) {
      emit(NotificationError(message: error.toString()));
    }
  }

  /// Start streaming notifications for real-time updates
  void _startNotificationStream(String userId) {
    _notificationsSubscription = _notificationRepository
        .streamUserNotifications(userId)
        .listen(
      (notifications) async {
        final unreadCount =
            await _notificationRepository.getUnreadNotificationCount(userId);
        if (notifications.isEmpty) {
          emit(const NotificationEmpty());
          return;
        }
        emit(NotificationSuccess(
          notifications: notifications,
          unreadCount: unreadCount,
        ),);
      },
      onError: (Object error) {
        logman.error('Failed to get user notifications: $error');
        emit(NotificationError(message: error.toString()));
      },
    );
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    final currentState = state;
    if (_currentUserId == null ||
        currentState is NotificationLoadingMore ||
        (currentState is NotificationSuccess && currentState.hasReachedMax)) {
      return;
    }

    List<NotificationModel> currentNotifications = [];
    int currentUnreadCount = 0;

    if (currentState is NotificationSuccess) {
      currentNotifications = currentState.notifications;
      currentUnreadCount = currentState.unreadCount;
    }

    emit(NotificationLoadingMore(
      notifications: currentNotifications,
      unreadCount: currentUnreadCount,
    ),);

    try {
      final notifications = await _notificationRepository.getUserNotifications(
        _currentUserId!,
        limit: 20,
        lastDocument: _lastDocument,
      );

      if (notifications.isEmpty) {
        emit(NotificationSuccess(
          notifications: currentNotifications,
          unreadCount: currentUnreadCount,
          hasReachedMax: true,
        ),);
        return;
      }

      final updatedNotifications =
          List<NotificationModel>.from(currentNotifications)
            ..addAll(notifications);

      emit(NotificationSuccess(
        notifications: updatedNotifications,
        unreadCount: currentUnreadCount,
        hasReachedMax: notifications.length < 20,
      ),);
    } catch (error) {
      emit(NotificationError(
        message: error.toString(),
        notifications: currentNotifications,
        unreadCount: currentUnreadCount,
      ),);
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_currentUserId == null) return;

    try {
      await _notificationRepository.markNotificationAsRead(notificationId);

      final currentState = state;
      if (currentState is NotificationSuccess) {
        // Update local state
        final updatedNotifications =
            currentState.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        final newUnreadCount = await _notificationRepository
            .getUnreadNotificationCount(_currentUserId!);

        emit(NotificationSuccess(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
          hasReachedMax: currentState.hasReachedMax,
        ),);
      }
    } catch (error) {
      final currentState = state;
      List<NotificationModel> currentNotifications = [];
      int currentUnreadCount = 0;

      if (currentState is NotificationSuccess) {
        currentNotifications = currentState.notifications;
        currentUnreadCount = currentState.unreadCount;
      }

      emit(NotificationError(
        message: error.toString(),
        notifications: currentNotifications,
        unreadCount: currentUnreadCount,
      ),);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      await _notificationRepository.markAllNotificationsAsRead(_currentUserId!);

      final currentState = state;
      if (currentState is NotificationSuccess) {
        // Update local state
        final updatedNotifications =
            currentState.notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();

        emit(NotificationSuccess(
          notifications: updatedNotifications,
          unreadCount: 0,
          hasReachedMax: currentState.hasReachedMax,
        ),);
      }
    } catch (error) {
      final currentState = state;
      List<NotificationModel> currentNotifications = [];
      int currentUnreadCount = 0;

      if (currentState is NotificationSuccess) {
        currentNotifications = currentState.notifications;
        currentUnreadCount = currentState.unreadCount;
      }

      emit(NotificationError(
        message: error.toString(),
        notifications: currentNotifications,
        unreadCount: currentUnreadCount,
      ),);
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationRepository.deleteNotification(notificationId);

      final currentState = state;
      if (currentState is NotificationSuccess) {
        // Update local state
        final updatedNotifications = currentState.notifications
            .where((notification) => notification.id != notificationId)
            .toList();

        final newUnreadCount = _currentUserId != null
            ? await _notificationRepository
                .getUnreadNotificationCount(_currentUserId!)
            : 0;

        emit(NotificationSuccess(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
          hasReachedMax: currentState.hasReachedMax,
        ),);
      }
    } catch (error) {
      final currentState = state;
      List<NotificationModel> currentNotifications = [];
      int currentUnreadCount = 0;

      if (currentState is NotificationSuccess) {
        currentNotifications = currentState.notifications;
        currentUnreadCount = currentState.unreadCount;
      }

      emit(NotificationError(
        message: error.toString(),
        notifications: currentNotifications,
        unreadCount: currentUnreadCount,
      ),);
    }
  }

  /// Save a new notification
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _notificationRepository.saveNotification(notification);
    } catch (error) {
      final currentState = state;
      List<NotificationModel> currentNotifications = [];
      int currentUnreadCount = 0;

      if (currentState is NotificationSuccess) {
        currentNotifications = currentState.notifications;
        currentUnreadCount = currentState.unreadCount;
      }

      emit(NotificationError(
        message: error.toString(),
        notifications: currentNotifications,
        unreadCount: currentUnreadCount,
      ),);
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    if (_currentUserId == null) return;

    emit(NotificationLoading());

    try {
      await _cancelSubscription();
      _startNotificationStream(_currentUserId!);
      await _updateUnreadCount(_currentUserId!);
    } catch (error) {
      emit(NotificationError(message: error.toString()));
    }
  }

  /// Update unread count
  Future<void> _updateUnreadCount(String userId) async {
    try {
      final count =
          await _notificationRepository.getUnreadNotificationCount(userId);
      final currentState = state;

      if (currentState is NotificationSuccess) {
        emit(NotificationSuccess(
          notifications: currentState.notifications,
          unreadCount: count,
          hasReachedMax: currentState.hasReachedMax,
        ),);
      }
    } catch (error) {
      logman.error('Failed to update unread count: $error');
    }
  }

  /// Delete old notifications
  Future<void> deleteOldNotifications({int daysOld = 30}) async {
    if (_currentUserId == null) return;

    try {
      await _notificationRepository.deleteOldNotifications(
        _currentUserId!,
        daysOld: daysOld,
      );
    } catch (error) {
      final currentState = state;
      List<NotificationModel> currentNotifications = [];
      int currentUnreadCount = 0;

      if (currentState is NotificationSuccess) {
        currentNotifications = currentState.notifications;
        currentUnreadCount = currentState.unreadCount;
      }

      emit(NotificationError(
        message: error.toString(),
        notifications: currentNotifications,
        unreadCount: currentUnreadCount,
      ),);
    }
  }

  /// Clear error and return to previous success state if available
  void clearError() {
    final currentState = state;
    if (currentState is NotificationError) {
      emit(NotificationSuccess(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
      ),);
    }
  }

  /// Cancel subscription and clean up
  Future<void> _cancelSubscription() async {
    await _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscription();
    super.close();
  }
}
