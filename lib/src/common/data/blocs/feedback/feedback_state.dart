part of 'feedback_cubit.dart';

sealed class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackSuccess extends FeedbackState {}

class FeedbackError extends FeedbackState {
  final String error;

  FeedbackError(this.error);

  @override
  List<Object> get props => [error];
}
