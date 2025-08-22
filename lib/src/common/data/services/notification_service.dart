import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:micro_journal/firebase_options.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> handleBack(RemoteMessage message) async {}

class NotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  static NotificationService? _instance;

  static Map<String, dynamic> get _serviceAccountCredentials {
    final privateKey =
        dotenv.env['FIREBASE_PRIVATE_KEY']?.replaceAll('\\n', '\n');

    if (dotenv.env['FIREBASE_PROJECT_ID'] == null ||
        privateKey == null ||
        dotenv.env['FIREBASE_CLIENT_EMAIL'] == null ||
        dotenv.env['FIREBASE_CLIENT_ID'] == null) {
      throw Exception('Missing Firebase environment variables');
    }

    return {
      'type': 'service_account',
      'project_id': dotenv.env['FIREBASE_PROJECT_ID'],
      'private_key_id': dotenv.env['FIREBASE_PRIVATE_KEY_ID'],
      'private_key': privateKey,
      'client_email': dotenv.env['FIREBASE_CLIENT_EMAIL'],
      'client_id': dotenv.env['FIREBASE_CLIENT_ID'],
      'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
      'token_uri': 'https://oauth2.googleapis.com/token',
      'auth_provider_x509_cert_url':
          'https://www.googleapis.com/oauth2/v1/certs',
      'client_x509_cert_url': dotenv.env['FIREBASE_CLIENT_X509_CERT_URL'] ?? '',
      'universe_domain': 'googleapis.com',
    };
  }

  static String get _fcmV1Url =>
      'https://fcm.googleapis.com/v1/projects/${dotenv.env['FIREBASE_PROJECT_ID']}/messages:send';

  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  NotificationService._({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  Future<void> initializeTimeZone() async {
    tz.initializeTimeZones();
  }

  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInitialize = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const likeChannel = AndroidNotificationChannel(
      'likes_channel',
      'Likes',
      description: 'Notifications for journal and comment likes',
      importance: Importance.high,
    );

    const commentChannel = AndroidNotificationChannel(
      'comments_channel',
      'Comments',
      description: 'Notifications for comments and replies',
      importance: Importance.high,
    );

    const reminderChannel = AndroidNotificationChannel(
      'reminders_channel',
      'Daily Reminders',
      description: 'Daily journal writing reminders',
    );

    const generalChannel = AndroidNotificationChannel(
      'general',
      'General',
      description: 'General notifications',
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(likeChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(commentChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  Future<void> _initializeFirebaseMessaging() async {
    await _messaging.requestPermission();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    logman.info('Received foreground message: ${message.messageId}');

    _showLocalNotificationFromRemote(message);
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    logman.info('Handling background message: ${message.messageId}');

    final notificationService = NotificationService.instance;
    await notificationService._initializeLocalNotifications();

    await notificationService._showLocalNotificationFromRemote(message);
  }

  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      logman.error('Failed to get current FCM token: $e');
      return null;
    }
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    logman.info('Handling a background message: ${message.messageId}');

    await NotificationService.handleBackgroundMessage(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    logman.info('Notification tapped: ${message.data}');

    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'like':
      case 'comment_like':
        _navigateToJournal(data['journalId'] as String);
      case 'comment':
      case 'comment_reply':
        _navigateToJournal(data['journalId'] as String);
      case 'daily_reminder':
        _navigateToNewJournal();
    }
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final Map<String, dynamic> data =
          jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'];

      switch (type) {
        case 'like':
        case 'comment_like':
          _navigateToJournal(data['journalId'] as String);
        case 'comment':
        case 'comment_reply':
          _navigateToJournal(data['journalId'] as String);
        case 'daily_reminder':
          _navigateToNewJournal();
      }
    }
  }

  Future<void> _showLocalNotificationFromRemote(RemoteMessage message) async {
    logman.info('Showing local notification from remote message');
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final type = data['type'] ?? 'general';

    String channelId;
    switch (type) {
      case 'like':
      case 'comment_like':
        channelId = 'likes_channel';
      case 'comment':
      case 'comment_reply':
        channelId = 'comments_channel';
      case 'daily_reminder':
        channelId = 'reminders_channel';
      default:
        channelId = 'general';
    }

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data),
    );
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'likes_channel':
        return 'Likes & Comment Likes';
      case 'comments_channel':
        return 'Comments & Replies';
      case 'reminders_channel':
        return 'Daily Reminders';
      default:
        return 'general';
    }
  }

  Future<String> _getAccessToken() async {
    try {
      final credentials =
          auth.ServiceAccountCredentials.fromJson(_serviceAccountCredentials);
      final client = await auth.clientViaServiceAccount(credentials, _scopes);
      final accessToken = client.credentials.accessToken.data;
      client.close();
      return accessToken;
    } catch (e) {
      logman.error('Failed to get access token: $e');
      rethrow;
    }
  }

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
          '$likerUsername liked your journal: "${_truncateText(journal.thoughts, 50)}"';
      final data = {
        'type': 'like',
        'journalId': journalId,
        'likerId': likerUserId,
      };

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'likes_channel',
          payload: jsonEncode(data),
        );
      } else {
        final ownerTokens = await _getUserFCMTokens(journalOwnerId);
        if (ownerTokens.isEmpty) return;

        for (final token in ownerTokens) {
          await _sendFCMNotificationV1(
            token: token,
            title: title,
            body: body,
            data: data,
          );
        }
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
      final commentText = comment.content;

      const title = 'New Comment Like! ❤️';
      final body =
          '$likerUsername liked your comment: "${_truncateText(commentText, 50)}"';
      final data = {
        'type': 'comment_like',
        'commentId': commentId,
        'journalId': journalId,
        'likerId': likerUserId,
      };

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'likes_channel',
          payload: jsonEncode(data),
        );
      } else {
        final ownerTokens = await _getUserFCMTokens(commentOwnerId);
        if (ownerTokens.isEmpty) return;

        for (final token in ownerTokens) {
          await _sendFCMNotificationV1(
            token: token,
            title: title,
            body: body,
            data: data,
          );
        }
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
          '$commenterUsername commented on your journal: "${_truncateText(commentText, 50)}"';
      final data = {
        'type': 'comment',
        'journalId': journalId,
        'commenterId': commenterUserId,
      };

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'comments_channel',
          payload: jsonEncode(data),
        );
      } else {
        final ownerTokens = await _getUserFCMTokens(journalOwnerId);
        if (ownerTokens.isEmpty) return;

        for (final token in ownerTokens) {
          await _sendFCMNotificationV1(
            token: token,
            title: title,
            body: body,
            data: data,
          );
        }
      }
    } catch (e) {
      logman.error('Failed to send comment notification: $e');
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
      final parentCommentText = parentComment.content;

      const title = 'New Reply! 💬';
      final body =
          '$replierUsername replied to your comment: "${_truncateText(replyText, 50)}"';
      final data = {
        'type': 'comment_reply',
        'parentCommentId': parentCommentId,
        'journalId': journalId,
        'replierId': replierUserId,
      };

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'comments_channel',
          payload: jsonEncode(data),
        );
      } else {
        final ownerTokens = await _getUserFCMTokens(parentCommentOwnerId);
        if (ownerTokens.isEmpty) return;

        for (final token in ownerTokens) {
          await _sendFCMNotificationV1(
            token: token,
            title: title,
            body: body,
            data: data,
          );
        }
      }
    } catch (e) {
      logman.error('Failed to send comment reply notification: $e');
    }
  }

  Future<void> sendDailyReminder(String userId, {bool showLocal = true}) async {
    try {
      const title = 'Time to Reflect ✨';
      const body = "Don't forget to write your daily journal entry!";
      final data = {'type': 'daily_reminder'};

      if (showLocal) {
        await _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'reminders_channel',
          payload: jsonEncode(data),
        );
      } else {
        final userTokens = await _getUserFCMTokens(userId);
        if (userTokens.isEmpty) return;

        for (final token in userTokens) {
          await _sendFCMNotificationV1(
            token: token,
            title: title,
            body: body,
            data: data,
          );
        }
      }
    } catch (e) {
      logman.error('Failed to send daily reminder: $e');
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    String? payload,
  }) async {
    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<List<String>> _getUserFCMTokens(String userId) async {
    try {
      logman.info('Fetching FCM tokens for user: $userId');

      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();

      if (data == null) {
        logman.error('No data found for user: $userId');
        return [];
      }

      final tokens = data['fcmTokens'];

      if (tokens is List && tokens.isNotEmpty) {
        final fcmTokens = tokens.whereType<String>().toList();

        logman.info('Found ${fcmTokens.length} FCM tokens for user: $userId');

        for (final token in fcmTokens) {
          logman.info('User FCM token: $token');
        }

        return fcmTokens;
      } else {
        logman.info(
          'No FCM tokens found for user: $userId, generating new token',
        );
        await assignTokenToUser(userId);

        final updatedDoc =
            await _firestore.collection('users').doc(userId).get();
        final updatedData = updatedDoc.data();

        if (updatedData != null &&
            updatedData['fcmTokens'] != null &&
            updatedData['fcmTokens'] is List) {
          final updatedTokens = updatedData['fcmTokens'] as List;
          final newTokens = updatedTokens.whereType<String>().toList();

          logman.info(
            'Assigned ${newTokens.length} new FCM tokens for user: $userId',
          );
          return newTokens;
        }

        logman.error(
          'fcmTokens field is missing or not a List for user: $userId',
        );
        return [];
      }
    } catch (e, s) {
      logman.error(
        'Failed to fetch FCM tokens for user: $userId — $e',
        stackTrace: s,
      );
      return [];
    }
  }

  Future<void> assignTokenToUser(String userId) async {
    try {
      logman.info('Assigning new FCM token to user: $userId');

      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayUnion([token]),
        });

        logman.info(
          'Successfully assigned FCM token to user: $userId - Token: $token',
        );
      } else {
        logman.error(
          'Failed to get FCM token from Firebase Messaging for user: $userId',
        );
      }
    } catch (e, s) {
      logman.error(
        'Failed to assign FCM token to user: $userId - $e',
        stackTrace: s,
      );
    }
  }

  /// Send FCM notification using Firebase Admin SDK v1 API
  Future<void> _sendFCMNotificationV1({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final message = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data,
          'android': {
            'priority': 'HIGH', // Move priority to the main android object
            'notification': {
              'channel_id': _getChannelIdFromType(data['type'] ?? 'general'),
              // Add other Android-specific notification settings here
              'sound': 'default',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
          'apns': {
            'headers': {
              'apns-priority': '10', // High priority for iOS
            },
            'payload': {
              'aps': {
                'alert': {
                  'title': title,
                  'body': body,
                },
                'sound': 'default',
                'badge': 1,
              },
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmV1Url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        logman.info('FCM notification sent successfully to $token');
      } else {
        logman.error(
          'Failed to send FCM notification: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      logman.error('Error sending FCM notification: $e');
    }
  }

  String _getChannelIdFromType(String type) {
    switch (type) {
      case 'like':
      case 'comment_like':
        return 'likes_channel';
      case 'comment':
      case 'comment_reply':
        return 'comments_channel';
      case 'daily_reminder':
        return 'reminders_channel';
      default:
        return 'general';
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  void _navigateToJournal(String? journalId) {
    if (journalId != null) {
      logman.info('Navigate to journal: $journalId');
      router.push(Routes.home.path);
    }
  }

  void _navigateToNewJournal() {
    logman.info('Navigate to new journal page');
    router.push(Routes.home.path);
  }
}
