part of 'journal_likes_cubit.dart';

abstract class JournalLikesState extends Equatable {
  const JournalLikesState();

  @override
  List<Object?> get props => [];
}

class JournalLikesInitial extends JournalLikesState {}

class JournalLikesLoading extends JournalLikesState {
  final String journalId;
  const JournalLikesLoading(this.journalId);

  @override
  List<Object?> get props => [journalId];
}

class JournalLikesSuccess extends JournalLikesState {
  final String journalId;
  final bool isLiked;
  const JournalLikesSuccess(this.journalId, this.isLiked);

  @override
  List<Object?> get props => [journalId, isLiked];
}

class JournalLikesError extends JournalLikesState {
  final String message;

  const JournalLikesError(this.message);

  @override
  List<Object?> get props => [message];
}
