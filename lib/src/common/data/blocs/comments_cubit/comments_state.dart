part of 'comments_cubit.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();
  @override
  List<Object> get props => [];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<CommentModel> comments;
  const CommentsLoaded(this.comments);

  @override
  List<Object> get props => [comments];
}

class CommentsError extends CommentsState {
  final String message;
  const CommentsError(this.message);
}
