import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();
  late NotificationCubit _notificationCubit;
  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _notificationCubit = NotificationCubit(
        notificationRepository: getIt<NotificationRepository>(),);
    _authRepository = getIt<AuthRepository>();
    final userId = _authRepository.currentUser?.uid;
    _notificationCubit.initialize(userId!);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _notificationCubit.loadMoreNotifications();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackIconButton(),
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            bloc: _notificationCubit,
            builder: (context, state) {
              if (state is NotificationSuccess && state.unreadCount > 0) {
                return TextButton.icon(
                  style: TextButton.styleFrom(
                    iconColor:
                        context.theme.primaryColor.withValues(alpha: 0.5),
                    textStyle: context.theme.textTheme.bodyMedium?.copyWith(
                      color: context.theme.primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  onPressed: () => _notificationCubit.markAllAsRead(),
                  icon: const Icon(Icons.done_all),
                  label: const Text('Mark All Read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                ),
              ),
              const PopupMenuItem(
                value: 'cleanup',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.cleaning_services),
                  title: Text('Delete Old'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        bloc: _notificationCubit,
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () => _notificationCubit.refresh(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          // if (state is NotificationInitial || state is NotificationLoading) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          final notifications = _getNotificationsFromState(state);
          final unreadCount = _getUnreadCountFromState(state);

          if (state is NotificationEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              if (unreadCount > 0) _buildUnreadCountHeader(unreadCount),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _notificationCubit.refresh(),
                  child: Skeletonizer(
                    enabled: state is NotificationLoading,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= notifications.length) {
                          return _buildBottomLoader(state);
                        }
                        return NotificationCard(
                          notification: notifications[index],
                          onTap: () =>
                              _handleNotificationTap(notifications[index]),
                          onDelete: () =>
                              _handleNotificationDelete(notifications[index]),
                          onMarkAsRead: () =>
                              _handleMarkAsRead(notifications[index]),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<NotificationModel> _getNotificationsFromState(NotificationState state) {
    if (state is NotificationSuccess) {
      return state.notifications;
    } else if (state is NotificationError) {
      return state.notifications;
    } else if (state is NotificationLoadingMore) {
      return state.notifications;
    } else {
      return List.generate(3, (_) => NotificationModel.empty());
    }
  }

  int _getUnreadCountFromState(NotificationState state) {
    if (state is NotificationSuccess) return state.unreadCount;
    if (state is NotificationError) return state.unreadCount;
    if (state is NotificationLoadingMore) return state.unreadCount;
    return 0;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "You'll see notifications here when you have them",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadCountHeader(int unreadCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            color: Theme.of(context).primaryColor,
            size: 12,
          ),
          const SizedBox(width: 8),
          Text(
            '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLoader(NotificationState state) {
    if (state is NotificationLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is NotificationSuccess && state.hasReachedMax) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No more notifications',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      _notificationCubit.markAsRead(notification.id);
    }

    _navigateToNotificationTarget(notification);
  }

  void _handleNotificationDelete(NotificationModel notification) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content:
            const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _notificationCubit.deleteNotification(notification.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleMarkAsRead(NotificationModel notification) {
    if (!notification.isRead) {
      _notificationCubit.markAsRead(notification.id);
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _notificationCubit.refresh();
      case 'cleanup':
        _showCleanupDialog();
    }
  }

  void _showCleanupDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Old Notifications'),
        content: const Text('Delete notifications older than 30 days?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _notificationCubit.deleteOldNotifications();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToNotificationTarget(NotificationModel notification) {
    if (notification.type == 'like' || notification.type == 'comment') {
      final extraData = {
        'postId': notification.data['journalId'],
        'notificationType': notification.type,
      };

      final commentId = notification.data['commentId'];
      if (commentId != null) {
        extraData['commentId'] = commentId;
      }
      context.push(
        Routes.notificationDetails.path,
        extra: extraData,
      );
    }
  }
}
