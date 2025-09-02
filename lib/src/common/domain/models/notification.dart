class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final String? fromUserId;
  final String? fromUsername;
  final String? fromUserAvatar;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    this.isRead = false,
    this.fromUserId,
    this.fromUsername,
    this.fromUserAvatar,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      isRead: json['isRead'] as bool? ?? false,
      fromUserId: json['fromUserId'] as String?,
      fromUsername: json['fromUsername'] as String?,
      fromUserAvatar: json['fromUserAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'fromUserAvatar': fromUserAvatar,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? fromUserId,
    String? fromUsername,
    String? fromUserAvatar,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUsername: fromUsername ?? this.fromUsername,
      fromUserAvatar: fromUserAvatar ?? this.fromUserAvatar,
    );
  }

  factory NotificationModel.empty() {
    return NotificationModel(
      id: '',
      userId: '',
      type: '',
      title: '',
      body: '',
      data: {},
      createdAt: DateTime.now(),
    );
  }
}
