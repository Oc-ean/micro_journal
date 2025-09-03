part of 'follow_cubit.dart';

abstract class FollowState extends Equatable {
  const FollowState();

  @override
  List<Object?> get props => [];
}

class FollowInitial extends FollowState {}

class FollowLoading extends FollowState {}

class FollowLoaded extends FollowState {
  final Map<String, bool> followingStatus;

  const FollowLoaded(this.followingStatus);

  @override
  List<Object?> get props => [followingStatus];
}

class FollowError extends FollowState {
  final String message;

  const FollowError(this.message);

  @override
  List<Object?> get props => [message];
}
