import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:micro_journal/src/common/common.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final NotificationService _notificationService;

  UserRepository(
      {FirebaseFirestore? firestore,
      FirebaseAuth? firebaseAuth,
      required NotificationService notificationService,})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService = notificationService;

  Future<UserModel?> getUserData(String userId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Stream<UserModel?> streamUserData(String userId) {
    logman.info('streamUserData: $userId');
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data is Map<String, dynamic>) {
          return UserModel.fromJson(data);
        }
      }
      return null;
    });
  }

  Future<void> updateUserProfile({
    String? username,
    String? avatarUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final updates = <String, dynamic>{};

      if (username != null) {
        updates['username'] = username;
        await user.updateDisplayName(username);
      }

      if (avatarUrl != null) {
        updates['avatarUrl'] = avatarUrl;
        await user.updatePhotoURL(avatarUrl);
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();

        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> createOrUpdateUser(UserModel user, {String? fcmToken}) async {
    try {
      final updates = user.toJson();
      if (fcmToken != null) {
        updates['fcmTokens'] = FieldValue.arrayUnion([fcmToken]);
      }

      await _firestore.collection('users').doc(user.id).set(
            updates,
            SetOptions(merge: true),
          );
    } catch (e) {
      logman.error('Failed to create/update user: $e');
      throw Exception('Failed to create/update user: $e');
    }
  }

  Future<void> updateFCMToken(String userId, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  Future<void> removeFCMToken(String userId, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([fcmToken]),
      });
    } catch (e) {
      throw Exception('Failed to remove FCM token: $e');
    }
  }

  Future<List<String>> getUserFCMTokens(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (data == null) return [];
      final tokens = data['fcmTokens'];
      if (tokens is List) {
        final fcmTokens = tokens.whereType<String>().toList();
        return fcmTokens;
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get user FCM tokens: $e');
    }
  }

  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection('users').doc(currentUserId),
        {
          'following': FieldValue.arrayUnion([targetUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      batch.update(
        _firestore.collection('users').doc(targetUserId),
        {
          'followers': FieldValue.arrayUnion([currentUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      logman.info('User $currentUserId started following $targetUserId');

      // Fetch current user's username to include in notification
      final currentUser = await getUserData(currentUserId);
      if (currentUser != null) {
        await _notificationService.sendFollowNotification(
          targetUserId: targetUserId,
          followerUserId: currentUserId,
          followerUsername: currentUser.username,
        );
      }
    } catch (e) {
      logman.error('Failed to follow user: $e');
      rethrow;
    }
  }

  /// Accept a follow request and trigger follow accepted notification
  Future<void> acceptFollowRequest(
      String currentUserId, String targetUserId,) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection('users').doc(currentUserId),
        {
          'followers': FieldValue.arrayUnion([targetUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      batch.update(
        _firestore.collection('users').doc(targetUserId),
        {
          'following': FieldValue.arrayUnion([currentUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      logman
          .info('User $targetUserId follow request accepted by $currentUserId');

      // Fetch accepting user’s username to include in notification
      final currentUser = await getUserData(currentUserId);
      if (currentUser != null) {
        await _notificationService.sendFollowAcceptedNotification(
          targetUserId: targetUserId,
          followerUserId: currentUserId,
          followerUsername: currentUser.username,
        );
      }
    } catch (e) {
      logman.error('Failed to accept follow request: $e');
      rethrow;
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection('users').doc(currentUserId),
        {
          'following': FieldValue.arrayRemove([targetUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      batch.update(
        _firestore.collection('users').doc(targetUserId),
        {
          'followers': FieldValue.arrayRemove([currentUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      logman.info('User $currentUserId unfollowed $targetUserId');
    } catch (e) {
      logman.error('Failed to unfollow user: $e');
      rethrow;
    }
  }

  /// Check if current user is following target user
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      final data = doc.data();
      if (doc.exists && data != null) {
        final following = List<String>.from(data['following'] as List? ?? []);
        return following.contains(targetUserId);
      }
      return false;
    } catch (e) {
      logman.error('Failed to check follow status: $e');
      return false;
    }
  }

  /// Get followers list
  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (doc.exists && data != null) {
        final followerIds = List<String>.from(data['followers'] as List? ?? []);

        final followers = await Future.wait(
          followerIds.map((id) => getUserData(id)),
        );

        return followers.whereType<UserModel>().toList();
      }
      return [];
    } catch (e) {
      logman.error('Failed to get followers: $e');
      return [];
    }
  }

  /// Get following list
  Future<List<UserModel>> getFollowing(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (doc.exists && data != null) {
        final followingIds =
            List<String>.from(data['following'] as List? ?? []);

        final following = await Future.wait(
          followingIds.map((id) => getUserData(id)),
        );

        return following.whereType<UserModel>().toList();
      }
      return [];
    } catch (e) {
      logman.error('Failed to get following: $e');
      return [];
    }
  }
}
