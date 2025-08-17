part of 'comments_likes_cubit.dart';

abstract class CommentLikesState extends Equatable {
  const CommentLikesState();

  @override
  List<Object?> get props => [];
}

class CommentLikesInitial extends CommentLikesState {}

class CommentLikesLoading extends CommentLikesState {}

class CommentLikesSuccess extends CommentLikesState {
  const CommentLikesSuccess();

  @override
  List<Object?> get props => [];
}

class CommentLikesError extends CommentLikesState {
  final String message;

  const CommentLikesError(this.message);

  @override
  List<Object?> get props => [message];
}
