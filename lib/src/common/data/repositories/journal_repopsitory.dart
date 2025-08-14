import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_journal/src/common/common.dart';

abstract class JournalRepository {
  Stream<List<JournalModel>> getJournals();
  Stream<JournalModel?> getJournal(String id);
  Future<void> createJournal(JournalModel journal);
  Future<void> updateJournal(JournalModel journal);
  Future<void> deleteJournal(String id);

  Stream<List<CommentModel>> getComments(String journalId);
  Future<void> addComment(CommentModel comment);
  Future<void> deleteComment(String commentId);

  Future<void> likeJournal(String journalId, String userId);
  Future<void> unlikeJournal(String journalId, String userId);
  Future<bool> isJournalLiked(String journalId, String userId);

  Future<void> likeComment(String commentId, String userId);
  Future<void> unlikeComment(String commentId, String userId);
}

class JournalRepositoryImpl implements JournalRepository {
  final FirebaseFirestore _firestore;

  JournalRepositoryImpl(this._firestore);

  @override
  Stream<List<JournalModel>> getJournals() {
    return _firestore
        .collection('journals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JournalModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<JournalModel?> getJournal(String id) {
    return _firestore.collection('journals').doc(id).snapshots().map(
        (snapshot) =>
            snapshot.exists ? JournalModel.fromJson(snapshot.data()!) : null);
  }

  @override
  Future<void> createJournal(JournalModel journal) async {
    await _firestore
        .collection('journals')
        .doc(journal.id)
        .set(journal.toJson());
  }

  @override
  Future<void> updateJournal(JournalModel journal) async {
    await _firestore
        .collection('journals')
        .doc(journal.id)
        .update(journal.toJson());
  }

  @override
  Future<void> deleteJournal(String id) async {
    await _firestore.collection('journals').doc(id).delete();
  }

  @override
  Stream<List<CommentModel>> getComments(String journalId) {
    return _firestore
        .collection('comments')
        .where('journalId', isEqualTo: journalId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> addComment(CommentModel comment) async {
    await _firestore
        .collection('comments')
        .doc(comment.id)
        .set(comment.toJson());
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }

  @override
  Future<void> likeJournal(String journalId, String userId) async {
    await _firestore.collection('journals').doc(journalId).update({
      'likesCount': FieldValue.increment(1),
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikeJournal(String journalId, String userId) async {
    await _firestore.collection('journals').doc(journalId).update({
      'likesCount': FieldValue.increment(-1),
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<bool> isJournalLiked(String journalId, String userId) async {
    final doc = await _firestore.collection('journals').doc(journalId).get();
    if (!doc.exists) return false;
    final likes = List<String>.from(doc.data()!['likes'] as List? ?? []);
    return likes.contains(userId);
  }

  @override
  Future<void> likeComment(String commentId, String userId) async {
    await _firestore.collection('comments').doc(commentId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikeComment(String commentId, String userId) async {
    await _firestore.collection('comments').doc(commentId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }
}
