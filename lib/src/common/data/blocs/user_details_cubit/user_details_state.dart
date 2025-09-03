part of 'user_details_cubit.dart';

abstract class UserDetailsState extends Equatable {
  const UserDetailsState();

  @override
  List<Object?> get props => [];
}

class UserDetailsInitial extends UserDetailsState {}

class UserDetailsLoading extends UserDetailsState {}

class UserDetailsLoaded extends UserDetailsState {
  final UserModel user;
  final List<JournalModel> recentPosts;

  const UserDetailsLoaded({
    required this.user,
    required this.recentPosts,
  });

  @override
  List<Object?> get props => [
        user,
        recentPosts,
      ];

  UserDetailsLoaded copyWith({
    UserModel? user,
    List<JournalModel>? recentPosts,
  }) {
    return UserDetailsLoaded(
      user: user ?? this.user,
      recentPosts: recentPosts ?? this.recentPosts,
    );
  }
}

class UserDetailsError extends UserDetailsState {
  final String message;

  const UserDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
