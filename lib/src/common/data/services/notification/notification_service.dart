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

part 'notification_service_extensions.dart';

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

  Future<AuthorizationStatus> getNotificationPermissionStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus;
  }

  Future<bool> areNotificationsEnabled() async {
    final status = await getNotificationPermissionStatus();
    return status == AuthorizationStatus.authorized;
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

    const followChannel = AndroidNotificationChannel(
      'follows_channel',
      'Follows',
      description: 'Notifications for follows',
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
        ?.createNotificationChannel(followChannel);

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
        _navigateToNotificationDetails(
          postId: data['journalId'] as String,
          notificationType: 'like',
        );
      case 'comment_like':
        _navigateToNotificationDetails(
          postId: data['journalId'] as String,
          commentId: data['commentId'] as String? ?? '',
          notificationType: 'comment_like',
        );
      case 'comment':
        _navigateToNotificationDetails(
          postId: data['journalId'] as String,
          notificationType: 'comment',
        );

      case 'comment_reply':
        _navigateToNotificationDetails(
          postId: data['journalId'] as String,
          commentId: data['parentCommentId'] as String? ?? '',
          notificationType: 'comment_reply',
        );

      case 'follow':
        _navigateToNotificationDetails(
          postId: data['journalId'] as String,
          notificationType: 'follow',
          followerId: data['followerId'] as String? ?? '',
        );
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
          _navigateToNotificationDetails(
            postId: data['journalId'] as String,
            notificationType: 'like',
          );
        case 'comment_like':
          _navigateToNotificationDetails(
            postId: data['journalId'] as String,
            commentId: data['commentId'] as String? ?? '',
            notificationType: 'comment_like',
          );
        case 'comment':
          _navigateToNotificationDetails(
            postId: data['journalId'] as String,
            notificationType: 'comment',
          );
        case 'comment_reply':
          _navigateToNotificationDetails(
            postId: data['journalId'] as String,
            commentId: data['parentCommentId'] as String? ?? '',
            notificationType: 'comment_reply',
          );

        case 'follow':
          _navigateToNotificationDetails(
            postId: data['journalId'] as String,
            notificationType: 'follow',
            followerId: data['followerId'] as String? ?? '',
          );
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
      case 'follow':
        channelId = 'follows_channel';
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
          getChannelName(channelId),
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data),
    );
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
          getChannelName(channelId),
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
          getChannelName(channelId),
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
            'priority': 'HIGH',
            'notification': {
              'channel_id': getChannelIdFromType(data['type'] ?? 'general'),
              'sound': 'default',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
          'apns': {
            'headers': {
              'apns-priority': '10',
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

  void _navigateToNotificationDetails({
    required String postId,
    String commentId = '',
    required String notificationType,
    String? followerId,
  }) {
    logman.info(
      'Navigate to notification details - PostId: $postId, CommentId: $commentId, Type: $notificationType',
    );
    if (notificationType == 'like' || notificationType == 'comment') {
      final extraData = {
        'postId': postId,
        'notificationType': notificationType,
      };

      if (commentId.trim().isNotEmpty) {
        extraData['commentId'] = commentId;
      }
      router.push(
        Routes.notificationDetails.path,
        extra: extraData,
      );
    } else {
      router.push(
        Routes.follow.path,
        extra: {
          'userId': followerId,
          'isFromNotificationPage': true,
        },
      );
    }
  }

  void _navigateToNewJournal() {
    logman.info('Navigate to new journal page');
    router.push(Routes.home.path);
  }

  Future<String?> getUserAvatarUrl(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return data['avatarUrl'] as String?;
      }
      return null;
    } catch (e) {
      logman.error('Failed to get user avatar for $userId: $e');
      return null;
    }
  }
}
