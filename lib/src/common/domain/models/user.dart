class UserModel {
  final String id;
  final String email;
  final String username;
  final String avatarUrl;
  final List<String> followers;
  final List<String> following;
  final int journals;
  final bool enabledAnonymousSharing;
  final List<String> fcmTokens;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
    this.followers = const [],
    this.following = const [],
    this.fcmTokens = const [],
    this.journals = 0,
    this.enabledAnonymousSharing = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
      followers: List<String>.from(json['followers'] as List? ?? []),
      following: List<String>.from(json['following'] as List? ?? []),
      enabledAnonymousSharing:
          json['enabledAnonymousSharing'] as bool? ?? false,
      journals: json['journals'] as int? ?? 0,
      fcmTokens: List<String>.from(json['fcmTokens'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'followers': followers,
      'following': following,
      'enabledAnonymousSharing': enabledAnonymousSharing,
      'journals': journals,
      'fcmTokens': fcmTokens,
    };
  }

  int get followersCount => followers.length;
  int get followingCount => following.length;

  bool isFollowing(String userId) {
    return following.contains(userId);
  }

  bool isFollowedBy(String userId) {
    return followers.contains(userId);
  }

  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      username: '',
      avatarUrl: '',
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    List<String>? followers,
    List<String>? following,
    int? journals,
    bool? enabledAnonymousSharing,
    List<String>? fcmTokens,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      enabledAnonymousSharing:
          enabledAnonymousSharing ?? this.enabledAnonymousSharing,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      journals: journals ?? this.journals,
    );
  }
}
