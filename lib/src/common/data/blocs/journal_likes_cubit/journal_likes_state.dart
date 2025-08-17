part of 'journal_likes_cubit.dart';

abstract class JournalLikesState extends Equatable {
  const JournalLikesState();

  @override
  List<Object?> get props => [];
}

class JournalLikesInitial extends JournalLikesState {}

class JournalLikesLoading extends JournalLikesState {}

class JournalLikesSuccess extends JournalLikesState {
  const JournalLikesSuccess();

  @override
  List<Object?> get props => [];
}

class JournalLikesError extends JournalLikesState {
  final String message;

  const JournalLikesError(this.message);

  @override
  List<Object?> get props => [message];
}
