import 'package:micro_journal/src/common/common.dart';

class CommentModel {
  final String id;
  final String journalId;
  final String content;
  final UserModel? user;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentCommentId;
  final List<String> likes;

  CommentModel({
    required this.id,
    required this.journalId,
    required this.content,
    this.user,
    this.isAnonymous = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.parentCommentId,
    this.likes = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journalId': journalId,
      'content': content,
      'user': isAnonymous ? null : user?.toJson(),
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'parentCommentId': parentCommentId,
      'likes': likes,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      journalId: json['journalId'] as String,
      content: json['content'] as String,
      user: json['user'] != null && !(json['isAnonymous'] as bool? ?? false)
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      parentCommentId: json['parentCommentId'] as String?,
      likes: List<String>.from(json['likes'] as List? ?? []),
    );
  }
}
