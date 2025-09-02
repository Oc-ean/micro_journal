import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_journal/src/common/common.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Save a notification to Firebase
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());

      logman.info('Notification saved: ${notification.id}');
    } catch (e) {
      logman.error('Failed to save notification: $e');
      rethrow;
    }
  }

  /// Get all notifications for a user
  Future<List<NotificationModel>> getUserNotifications(
    String userId, {
    int limit = 50,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          // Remove orderBy or handle differently
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot snapshot = await query.get();

      // Sort locally instead
      final notifications = snapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data != null) {
              return NotificationModel.fromJson(data as Map<String, dynamic>);
            } else {
              return null;
            }
          })
          .whereType<NotificationModel>()
          .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    } catch (e) {
      logman.error('Failed to get user notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      logman.error('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = _firestore.batch();

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      logman.error('Failed to mark all notifications as read: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final unreadCount = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null && data['isRead'] == false;
      }).length;

      return unreadCount;
    } catch (e) {
      logman.error('Failed to get unread notification count: $e');
      return 0;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      logman.error('Failed to delete notification: $e');
    }
  }

  /// Stream of user notifications (for real-time updates)
  Stream<List<NotificationModel>> streamUserNotifications(
    String userId, {
    int limit = 20,
  }) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications.take(limit).toList();
    });
  }

  /// Delete old notifications (cleanup utility)
  Future<void> deleteOldNotifications(String userId, {int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: cutoffDate.millisecondsSinceEpoch)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      logman.info(
        'Deleted ${snapshot.docs.length} old notifications for user: $userId',
      );
    } catch (e) {
      logman.error('Failed to delete old notifications: $e');
    }
  }
}
