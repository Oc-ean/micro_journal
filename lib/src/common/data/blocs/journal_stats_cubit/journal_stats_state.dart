part of 'journal_stats_cubit.dart';

abstract class JournalStatsState extends Equatable {
  const JournalStatsState();

  @override
  List<Object?> get props => [];
}

class JournalStatsInitial extends JournalStatsState {
  const JournalStatsInitial();
}

class JournalStatsLoading extends JournalStatsState {
  const JournalStatsLoading();
}

class JournalStatsLoaded extends JournalStatsState {
  final JournalStats stats;

  const JournalStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class JournalStatsError extends JournalStatsState {
  final String message;

  const JournalStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
