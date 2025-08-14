import 'package:micro_journal/src/common/common.dart';

class JournalModel {
  final String id;
  final DateTime date;
  final Mood mood;
  final String thoughts;
  final String? intention;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAnonymous;
  final int likesCount;
  final int commentsCount;
  final UserModel? user;

  JournalModel({
    required this.id,
    required this.date,
    required this.mood,
    required this.thoughts,
    this.intention,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isAnonymous = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.user,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood.toJson(),
      'thoughts': thoughts,
      'intention': intention,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isAnonymous': isAnonymous,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'user': isAnonymous ? null : user?.toJson(),
    };
  }

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: Mood.fromJson(json['mood'] as Map<String, dynamic>),
      thoughts: json['thoughts'] as String,
      intention: json['intention'] as String?,
      tags: List<String>.from(json['tags'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      user: json['user'] != null && !(json['isAnonymous'] as bool? ?? false)
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  bool get isToday {
    final now = DateTime.now();
    return dateOnly == DateTime(now.year, now.month, now.day);
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  List<String> get hashTags => tags.map((tag) => '#$tag').toList();
}
