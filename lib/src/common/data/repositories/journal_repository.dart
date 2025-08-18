import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_journal/src/common/common.dart';

class JournalRepository {
  final FirebaseFirestore _firestore;

  JournalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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

  Future<void> createJournal(JournalModel journal) async {
    await _firestore
        .collection('journals')
        .doc(journal.id)
        .set(journal.toJson());
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
  }

  Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }

  Future<void> likeJournal(String journalId, String userId) async {
    await _firestore.collection('journals').doc(journalId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
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
  }

  Future<void> unlikeComment(String commentId, String userId) async {
    await _firestore.collection('comments').doc(commentId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }
}
