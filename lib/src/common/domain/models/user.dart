class UserModel {
  final String id;
  final String username;
  final String avatarUrl;
  final List<UserModel> followers;
  final List<UserModel> following;

  UserModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.followers = const [],
    this.following = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
      followers: (json['followers'] as List<dynamic>?)
              ?.map((follower) =>
                  UserModel.fromJson(follower as Map<String, dynamic>),)
              .toList() ??
          [],
      following: (json['following'] as List<dynamic>?)
              ?.map((following) =>
                  UserModel.fromJson(following as Map<String, dynamic>),)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'followers': followers.map((follower) => follower.toJson()).toList(),
      'following': following.map((following) => following.toJson()).toList(),
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
}
