import 'package:micro_journal/src/common/common.dart';

class CommentModel {
  final String id;
  final UserModel user;
  final String text;
  int likes;
  final List<CommentModel> replies;
  final DateTime timestamp;
  bool isLiked;

  CommentModel({
    String? id,
    required this.user,
    required this.text,
    this.likes = 0,
    this.replies = const [],
    DateTime? timestamp,
    this.isLiked = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
