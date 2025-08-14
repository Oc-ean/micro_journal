import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:micro_journal/src/common/common.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  UserRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

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

  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.id);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        await userRef.update({
          'email': user.email,
          'username': user.username,
          'avatarUrl': user.avatarUrl,
        });
      } else {
        await userRef.set(user.toJson());
      }
    } catch (e) {
      throw Exception('Failed to create/update user: $e');
    }
  }
}
