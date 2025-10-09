part of 'notification_service.dart';

extension NotificationServiceExtensions on NotificationService {
  Future<void> sendLikeNotification({
    required String journalId,
    required String journalOwnerId,
    required String likerUserId,
    required String likerUsername,
    bool showLocal = false,
  }) async {
    try {
      final journalDoc =
          await _firestore.collection('journals').doc(journalId).get();
      if (!journalDoc.exists) return;

      final journal = JournalModel.fromJson(journalDoc.data()!);
      const title = 'New Like!';
      final body =
          '$likerUsername liked your journal: "${truncateText(journal.thoughts, 50)}"';
      final data = {
        'type': 'like',
        'journalId': journalId,
        'likerId': likerUserId,
      };

      final avatarUrl = await getUserAvatarUrl(likerUserId);

      final notification = NotificationModel(
        id: generateNotificationId(),
        userId: journalOwnerId,
        type: 'like',
        title: title,
        body: body,
        data: data,
        createdAt: DateTime.now(),
        fromUserId: likerUserId,
        fromUsername: likerUsername,
        fromUserAvatar: avatarUrl,
      );

      await getIt<NotificationRepository>().saveNotification(notification);

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'likes_channel',
          payload: jsonEncode(data),
        );
      } else {
        await _sendPushNotificationIfEnabled(
          userId: journalOwnerId,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      logman.error('Failed to send like notification: $e');
    }
  }

  Future<void> sendCommentLikeNotification({
    required String commentId,
    required String commentOwnerId,
    required String likerUserId,
    required String likerUsername,
    required String journalId,
    bool showLocal = false,
  }) async {
    try {
      final commentDoc =
          await _firestore.collection('comments').doc(commentId).get();
      if (!commentDoc.exists) return;

      final comment = CommentModel.fromJson(commentDoc.data()!);
      const title = 'New Comment Like! ❤️';
      final body =
          '$likerUsername liked your comment: "${truncateText(comment.content, 50)}"';
      final data = {
        'type': 'comment_like',
        'commentId': commentId,
        'journalId': journalId,
        'likerId': likerUserId,
      };

      final avatarUrl = await getUserAvatarUrl(likerUserId);

      final notification = NotificationModel(
        id: generateNotificationId(),
        userId: commentOwnerId,
        type: 'comment_like',
        title: title,
        body: body,
        data: data,
        createdAt: DateTime.now(),
        fromUserId: likerUserId,
        fromUsername: likerUsername,
        fromUserAvatar: avatarUrl,
      );

      await getIt<NotificationRepository>().saveNotification(notification);

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'likes_channel',
          payload: jsonEncode(data),
        );
      } else {
        await _sendPushNotificationIfEnabled(
          userId: commentOwnerId,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      logman.error('Failed to send comment like notification: $e');
    }
  }

  Future<void> sendCommentNotification({
    required String journalId,
    required String journalOwnerId,
    required String commenterUserId,
    required String commenterUsername,
    required String commentText,
    bool showLocal = false,
  }) async {
    try {
      final journalDoc =
          await _firestore.collection('journals').doc(journalId).get();
      if (!journalDoc.exists) return;

      const title = 'New Comment!';
      final body =
          '$commenterUsername commented on your journal: "${truncateText(commentText, 50)}"';
      final data = {
        'type': 'comment',
        'journalId': journalId,
        'commenterId': commenterUserId,
      };

      final avatarUrl = await getUserAvatarUrl(commenterUserId);

      final notification = NotificationModel(
        id: generateNotificationId(),
        userId: journalOwnerId,
        type: 'comment',
        title: title,
        body: body,
        data: data,
        createdAt: DateTime.now(),
        fromUserId: commenterUserId,
        fromUsername: commenterUsername,
        fromUserAvatar: avatarUrl,
      );

      await getIt<NotificationRepository>().saveNotification(notification);

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'comments_channel',
          payload: jsonEncode(data),
        );
      } else {
        await _sendPushNotificationIfEnabled(
          userId: journalOwnerId,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      logman.error('Failed to send comment notification: $e');
    }
  }

  Future<void> sendFollowNotification({
    required String targetUserId,
    required String followerUserId,
    required String followerUsername,
    bool showLocal = false,
  }) async {
    try {
      const title = 'New Follower! 👥';
      final body = '$followerUsername started following you';
      final data = {
        'type': 'follow',
        'followerId': followerUserId,
        'targetUserId': targetUserId,
      };

      final avatarUrl = await getUserAvatarUrl(followerUserId);

      final notification = NotificationModel(
        id: generateNotificationId(),
        userId: targetUserId,
        type: 'follow',
        title: title,
        body: body,
        data: data,
        createdAt: DateTime.now(),
        fromUserId: followerUserId,
        fromUsername: followerUsername,
        fromUserAvatar: avatarUrl,
      );

      await getIt<NotificationRepository>().saveNotification(notification);

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'follows_channel',
          payload: jsonEncode(data),
        );
      } else {
        await _sendPushNotificationIfEnabled(
          userId: targetUserId,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      logman.error('Failed to send follow notification: $e');
    }
  }

  Future<void> sendFollowAcceptedNotification({
    required String targetUserId,
    required String followerUserId,
    required String followerUsername,
    bool showLocal = false,
  }) async {
    try {
      const title = 'Follow Request Accepted! 👥';
      final body = '$followerUsername started following you';
      final data = {
        'type': 'follow_accepted',
        'followerId': followerUserId,
        'targetUserId': targetUserId,
      };

      final avatarUrl = await getUserAvatarUrl(followerUserId);

      final notification = NotificationModel(
        id: generateNotificationId(),
        userId: targetUserId,
        type: 'follow_accepted',
        title: title,
        body: body,
        data: data,
        createdAt: DateTime.now(),
        fromUserId: followerUserId,
        fromUsername: followerUsername,
        fromUserAvatar: avatarUrl,
      );

      await getIt<NotificationRepository>().saveNotification(notification);

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'follows_channel',
          payload: jsonEncode(data),
        );
      } else {
        await _sendPushNotificationIfEnabled(
          userId: targetUserId,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      logman.error('Failed to send follow notification: $e');
    }
  }

  Future<void> sendCommentReplyNotification({
    required String parentCommentId,
    required String parentCommentOwnerId,
    required String replierUserId,
    required String replierUsername,
    required String replyText,
    required String journalId,
    bool showLocal = false,
  }) async {
    try {
      final parentCommentDoc =
          await _firestore.collection('comments').doc(parentCommentId).get();
      if (!parentCommentDoc.exists) return;

      final parentComment = CommentModel.fromJson(parentCommentDoc.data()!);
      const title = 'New Reply! 💬';
      final body =
          '$replierUsername replied to your comment: "${truncateText(replyText, 50)}"';
      final data = {
        'type': 'comment_reply',
        'parentCommentId': parentCommentId,
        'journalId': journalId,
        'replierId': replierUserId,
      };

      final avatarUrl = await getUserAvatarUrl(replierUserId);

      final notification = NotificationModel(
        id: generateNotificationId(),
        userId: parentCommentOwnerId,
        title: title,
        body: body,
        type: 'comment_reply',
        data: data,
        createdAt: DateTime.now(),
        fromUserId: replierUserId,
        fromUsername: replierUsername,
        fromUserAvatar: avatarUrl,
      );

      await getIt<NotificationRepository>().saveNotification(notification);

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'comments_channel',
          payload: jsonEncode(data),
        );
      } else {
        await _sendPushNotificationIfEnabled(
          userId: parentCommentOwnerId,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      logman.error('Failed to send comment reply notification: $e');
    }
  }

  Future<void> scheduleDailyReminder() async {
    try {
      const title = 'Time to Reflect ✨';
      const body = "Don't forget to write your daily journal entry!";
      final data = {'type': 'daily_reminder'};

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _localNotifications.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Daily Reminders',
            channelDescription: 'Daily journal writing reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: jsonEncode(data),
      );

      logman.info('Daily reminder scheduled for 9:00 AM');
    } catch (e) {
      logman.error('Failed to schedule daily reminder: $e');
    }
  }

  Future<void> cancelDailyReminder() async {
    try {
      await _localNotifications.cancel(0);
      logman.info('Daily reminder cancelled');
    } catch (e) {
      logman.error('Failed to cancel daily reminder: $e');
    }
  }

  Future<void> _sendPushNotificationIfEnabled({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final shouldSendPush = await _shouldSendPushNotification(userId);
    if (!shouldSendPush) return;

    final tokens = await _getUserFCMTokens(userId);
    if (tokens.isEmpty) return;

    final stringData =
        data.map((key, value) => MapEntry(key, value.toString()));

    for (final token in tokens) {
      await _sendFCMNotificationV1(
        token: token,
        title: title,
        body: body,
        data: stringData,
      );
    }
  }

  Future<bool> _shouldSendPushNotification(String userId) async {
    try {
      final systemEnabled = await areNotificationsEnabled();
      if (!systemEnabled) return false;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return true;

      final userData = userDoc.data();
      final enablePushNotifications = userData?['enablePushNotifications'];
      return enablePushNotifications == true || enablePushNotifications == null;
    } catch (e) {
      logman.error('Failed to check push notification preference: $e');
      return true;
    }
  }
}
