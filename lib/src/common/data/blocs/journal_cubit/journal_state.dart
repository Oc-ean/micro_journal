part of 'journal_cubit.dart';

abstract class JournalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JournalInitial extends JournalState {}

class JournalLoading extends JournalState {}

class JournalLoaded extends JournalState {
  final List<JournalModel> journals;

  JournalLoaded({
    this.journals = const [],
  });

  @override
  List<Object?> get props => [journals];
}

class JournalError extends JournalState {
  final String message;

  JournalError(this.message);

  @override
  List<Object?> get props => [message];
}

class JournalCreating extends JournalState {}

class JournalEmpty extends JournalState {}

class JournalCreated extends JournalState {
  final JournalModel journal;

  JournalCreated(this.journal);

  @override
  List<Object?> get props => [journal];
}

class JournalUpdating extends JournalState {
  final String journalId;

  JournalUpdating(this.journalId);

  @override
  List<Object?> get props => [journalId];
}

class JournalUpdated extends JournalState {
  final JournalModel journal;

  JournalUpdated(this.journal);

  @override
  List<Object?> get props => [journal];
}

class JournalDeleting extends JournalState {
  final String journalId;

  JournalDeleting(this.journalId);

  @override
  List<Object?> get props => [journalId];
}

class JournalDeleted extends JournalState {
  final String journalId;

  JournalDeleted(this.journalId);

  @override
  List<Object?> get props => [journalId];
}
