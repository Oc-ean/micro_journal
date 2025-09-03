import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_journal/src/common/common.dart';

class JournalRepository {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  JournalRepository({
    FirebaseFirestore? firestore,
    required NotificationService notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService = notificationService;

  Stream<List<JournalModel>> getJournals() {
    return _firestore
        .collection('journals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JournalModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Stream<JournalModel?> getJournal(String id) {
    return _firestore.collection('journals').doc(id).snapshots().map(
          (snapshot) =>
              snapshot.exists ? JournalModel.fromJson(snapshot.data()!) : null,
        );
  }

  Future<JournalModel?> getJournalById(String journalId) async {
    try {
      logman.info('Fetching journal with ID: $journalId');

      final doc = await _firestore.collection('journals').doc(journalId).get();

      if (!doc.exists) {
        logman.info('Journal not found with ID: $journalId');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        logman.error('No data found for journal: $journalId');
        return null;
      }

      final userId = data['userId'] as String?;
      UserModel? user;

      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data() != null) {
          user = UserModel.fromJson(userDoc.data()!);
        }
      }

      final journal = JournalModel.fromJson(data).copyWith(user: user);
      logman.info('Successfully fetched journal: $journalId');
      return journal;
    } catch (e, s) {
      logman.error('Failed to fetch journal $journalId: $e', stackTrace: s);
      return null;
    }
  }

  Future<void> createJournal(JournalModel journal) async {
    final userRef = _firestore.collection('users').doc(journal.user!.id);
    final journalRef = _firestore.collection('journals').doc(journal.id);

    final batch = _firestore.batch();
    batch.set(journalRef, journal.toJson());

    batch.update(userRef, {
      'journals': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> updateJournal(JournalModel journal) async {
    await _firestore
        .collection('journals')
        .doc(journal.id)
        .update(journal.toJson());
  }

  Future<void> deleteJournal(String id) async {
    await _firestore.collection('journals').doc(id).delete();
  }

  Future<List<JournalModel>> getJournalsForMonth(
    DateTime month,
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('journals')
          .where('user.id', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => JournalModel.fromJson(doc.data()))
          .where((journal) {
        final date = journal.createdAt;
        return date.year == month.year && date.month == month.month;
      }).toList();
    } catch (e) {
      logman.error('Fallback month journals failed: $e');
      return [];
    }
  }

  Stream<List<CommentModel>> getComments(String journalId) {
    return _firestore
        .collection('comments')
        .where('journalId', isEqualTo: journalId)
        .snapshots()
        .map(
      (snapshot) {
        final comments = snapshot.docs
            .map((doc) => CommentModel.fromJson(doc.data()))
            .toList();

        comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return comments;
      },
    );
  }

  Future<void> addComment(CommentModel comment) async {
    final batch = _firestore.batch();

    final commentRef = _firestore.collection('comments').doc(comment.id);
    batch.set(commentRef, comment.toJson());
    final journalRef = _firestore.collection('journals').doc(comment.journalId);
    batch.update(journalRef, {
      'commentsCount': FieldValue.increment(1),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await batch.commit();

    await _sendCommentNotification(comment);

    if (comment.parentCommentId != null) {
      await _sendCommentReplyNotification(comment, comment.parentCommentId!);
    }
  }

  Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }

  Future<void> likeJournal(String journalId, String userId) async {
    await _firestore.collection('journals').doc(journalId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });

    await _sendLikeNotification(journalId, userId);
  }

  Future<void> unlikeJournal(String journalId, String userId) async {
    await _firestore.collection('journals').doc(journalId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  Future<bool> isJournalLiked(String journalId, String userId) async {
    final doc = await _firestore.collection('journals').doc(journalId).get();
    if (!doc.exists) return false;
    final likes = List<String>.from(doc.data()!['likes'] as List? ?? []);
    return likes.contains(userId);
  }

  Future<void> likeComment(String commentId, String userId) async {
    await _firestore.collection('comments').doc(commentId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
    await _sendCommentLikeNotification(commentId, userId);
  }

  Future<void> unlikeComment(String commentId, String userId) async {
    await _firestore.collection('comments').doc(commentId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> _sendCommentNotification(CommentModel comment) async {
    try {
      final journalDoc =
          await _firestore.collection('journals').doc(comment.journalId).get();
      if (!journalDoc.exists) return;

      final journal = JournalModel.fromJson(journalDoc.data()!);
      final journalOwnerId = journal.user?.id;

      if (journalOwnerId == null || journalOwnerId == comment.user?.id) return;

      final commenterUsername = comment.user?.username ?? 'Someone';

      await _notificationService.sendCommentNotification(
        journalId: comment.journalId,
        journalOwnerId: journalOwnerId,
        commenterUserId: comment.user?.id ?? '',
        commenterUsername: commenterUsername,
        commentText: comment.content,
      );
    } catch (e) {
      logman.error('Failed to send comment notification: $e');
    }
  }

  Future<void> _sendLikeNotification(String journalId, String userId) async {
    try {
      final journalDoc =
          await _firestore.collection('journals').doc(journalId).get();
      if (!journalDoc.exists) return;

      final journal = JournalModel.fromJson(journalDoc.data()!);
      final journalOwnerId = journal.user?.id;

      if (journalOwnerId == null || journalOwnerId == userId) return;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final user = UserModel.fromJson(userDoc.data()!);
      final userName = user.username;

      logman.info(
        'Sending like notification for journal: $journalId , journalOwnerId: $journalOwnerId, likerUserId: $userId, likerUsername: $userName',
      );
      await _notificationService.sendLikeNotification(
        journalId: journalId,
        journalOwnerId: journalOwnerId,
        likerUserId: userId,
        likerUsername: userName,
      );
    } catch (e) {
      logman.error('Failed to send like notification: $e');
    }
  }

  Future<void> _sendCommentLikeNotification(
    String commentId,
    String userId,
  ) async {
    try {
      final commentDoc =
          await _firestore.collection('comments').doc(commentId).get();
      if (!commentDoc.exists) return;

      final comment = CommentModel.fromJson(commentDoc.data()!);
      final commentOwnerId = comment.user?.id;

      if (commentOwnerId == null || commentOwnerId == userId) return;

      final likerDoc = await _firestore.collection('users').doc(userId).get();
      if (!likerDoc.exists) return;

      final likeUser = UserModel.fromJson(likerDoc.data()!);

      final likerUsername = likeUser.username;

      await _notificationService.sendCommentLikeNotification(
        commentId: commentId,
        commentOwnerId: commentOwnerId,
        likerUserId: userId,
        likerUsername: likerUsername,
        journalId: comment.journalId,
      );
    } catch (e) {
      logman.error('Failed to send comment like notification: $e');
    }
  }

  Future<void> _sendCommentReplyNotification(
    CommentModel reply,
    String parentCommentId,
  ) async {
    try {
      final parentCommentDoc =
          await _firestore.collection('comments').doc(parentCommentId).get();
      if (!parentCommentDoc.exists) return;

      final parentComment = CommentModel.fromJson(parentCommentDoc.data()!);
      final parentCommentOwnerId = parentComment.user?.id;

      if (parentCommentOwnerId == null ||
          parentCommentOwnerId == reply.user?.id) {
        return;
      }

      final replierUsername = reply.user?.username ?? 'Someone';

      await _notificationService.sendCommentReplyNotification(
        parentCommentId: parentCommentId,
        parentCommentOwnerId: parentCommentOwnerId,
        replierUserId: reply.user?.id ?? '',
        replierUsername: replierUsername,
        replyText: reply.content,
        journalId: reply.journalId,
      );
    } catch (e) {
      logman.error('Failed to send comment reply notification: $e');
    }
  }
}
