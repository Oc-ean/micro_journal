import 'package:micro_journal/src/common/common.dart';

class JournalModel {
  final String id;
  final Mood mood;
  final String thoughts;
  final String? intention;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAnonymous;
  final List<String>? likes;
  final int commentsCount;
  final UserModel? user;

  JournalModel({
    required this.id,
    required this.mood,
    required this.thoughts,
    this.intention,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isAnonymous = false,
    this.likes,
    this.commentsCount = 0,
    this.user,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood.toJson(),
      'thoughts': thoughts,
      'intention': intention,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isAnonymous': isAnonymous,
      'likes': likes,
      'commentsCount': commentsCount,
      'user': user?.toJson(),
    };
  }

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'] as String,
      mood: Mood.fromJson(json['mood'] as Map<String, dynamic>),
      thoughts: json['thoughts'] as String,
      intention: json['intention'] as String?,
      tags: List<String>.from(json['tags'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      likes: List<String>.from(json['likes'] as List? ?? []),
      commentsCount: json['commentsCount'] as int? ?? 0,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  JournalModel copyWith({
    String? id,
    Mood? mood,
    String? thoughts,
    String? intention,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAnonymous,
    List<String>? likes,
    int? commentsCount,
    UserModel? user,
  }) {
    return JournalModel(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      thoughts: thoughts ?? this.thoughts,
      intention: intention ?? this.intention,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      user: user ?? this.user,
    );
  }

  DateTime get dateOnly =>
      DateTime(createdAt.year, createdAt.month, createdAt.day);

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

  factory JournalModel.sampleData() {
    return JournalModel(
      id: 'Sauce',
      mood: Mood(value: 'happy', emoji: '😊'),
      thoughts: 'Random',
      user: UserModel(
        id: 'd2',
        username: 'John',
        email: 'Johndoe@gmail.com',
        avatarUrl: 'ww',
      ),
    );
  }
}
