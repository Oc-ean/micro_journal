class UserModel {
  final String id;
  final String email;
  final String username;
  final String avatarUrl;
  final List<UserModel> followers;
  final List<UserModel> following;
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
      followers: (json['followers'] as List<dynamic>?)
              ?.map(
                (follower) =>
                    UserModel.fromJson(follower as Map<String, dynamic>),
              )
              .toList() ??
          [],
      following: (json['following'] as List<dynamic>?)
              ?.map(
                (following) =>
                    UserModel.fromJson(following as Map<String, dynamic>),
              )
              .toList() ??
          [],
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
      'followers': followers.map((follower) => follower.toJson()).toList(),
      'following': following.map((following) => following.toJson()).toList(),
      'enabledAnonymousSharing': enabledAnonymousSharing,
      'journals': journals,
      'fcmTokens': fcmTokens,
    };
  }

  int get followersCount => followers.length;
  int get followingCount => following.length;

  bool isFollowing(String userId) {
    return following.any((user) => user.id == userId);
  }

  bool isFollowedBy(String userId) {
    return followers.any((user) => user.id == userId);
  }

  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      username: '',
      avatarUrl: '',
      followers: [],
      following: [],
    );
  }
}
