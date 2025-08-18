import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'journal_stats_state.dart';

class JournalStatsCubit extends Cubit<JournalStatsState> {
  final JournalRepository _journalRepository;
  StreamSubscription<List<JournalModel>>? _journalsSubscription;

  JournalStatsCubit({
    required JournalRepository journalRepository,
  })  : _journalRepository = journalRepository,
        super(const JournalStatsInitial());

  void loadStats({String? userId}) {
    emit(const JournalStatsLoading());

    try {
      _journalsSubscription?.cancel();
      _journalsSubscription = _journalRepository.getJournals().listen(
        (journals) {
          try {
            // Filter by userId if provided
            final filteredJournals = userId != null
                ? journals
                    .where((journal) => journal.user!.id == userId)
                    .toList()
                : journals;

            final stats = _calculateStats(filteredJournals);
            emit(JournalStatsLoaded(stats));
          } catch (e) {
            logman.error('Error calculating stats: $e');
            emit(JournalStatsError('Failed to calculate statistics: $e'));
          }
        },
        onError: (Object error) {
          logman.error('Error loading journals for stats: $error');
          emit(JournalStatsError('Failed to load journal data: $error'));
        },
      );
    } catch (e) {
      logman.error('Error setting up stats stream: $e');
      emit(JournalStatsError('Failed to initialize statistics: $e'));
    }
  }

  Future<void> loadStatsForMonth(DateTime month, String userId) async {
    emit(const JournalStatsLoading());

    try {
      final journals =
          await _journalRepository.getJournalsForMonth(month, userId);
      final stats = _calculateStats(journals);
      emit(JournalStatsLoaded(stats));
    } catch (e) {
      logman.error('Error loading monthly stats: $e');
      emit(JournalStatsError('Failed to load monthly statistics: $e'));
    }
  }

  JournalStats _calculateStats(List<JournalModel> journals) {
    if (journals.isEmpty) {
      return const JournalStats(
        totalEntries: 0,
        currentStreak: 0,
        totalWords: 0,
        moods: [],
      );
    }

    // Calculate total entries
    final totalEntries = journals.length;

    final totalWords = journals.fold<int>(
      0,
      (sum, journal) => sum + _countWords(journal.thoughts),
    );

    final currentStreak = _calculateCurrentStreak(journals);

    final moods = _calculateMoodDistribution(journals);

    return JournalStats(
      totalEntries: totalEntries,
      currentStreak: currentStreak,
      totalWords: totalWords,
      moods: moods,
    );
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  int _calculateCurrentStreak(List<JournalModel> journals) {
    if (journals.isEmpty) return 0;

    final sortedJournals = List<JournalModel>.from(journals)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime currentDate = todayNormalized;

    final mostRecentEntry = sortedJournals.first;
    final mostRecentDate = DateTime(
      mostRecentEntry.createdAt.year,
      mostRecentEntry.createdAt.month,
      mostRecentEntry.createdAt.day,
    );

    final daysDifference = todayNormalized.difference(mostRecentDate).inDays;
    if (daysDifference > 1) return 0;

    if (daysDifference == 1) {
      currentDate = mostRecentDate;
    }

    for (int i = 0; i < sortedJournals.length; i++) {
      final entryDate = DateTime(
        sortedJournals[i].createdAt.year,
        sortedJournals[i].createdAt.month,
        sortedJournals[i].createdAt.day,
      );

      if (entryDate == currentDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (entryDate.isBefore(currentDate)) {
        break;
      }
    }

    return streak;
  }

  List<Mood> _calculateMoodDistribution(List<JournalModel> journals) {
    final moodCounts = <String, int>{};

    for (final journal in journals) {
      final moodValue = journal.mood.value;
      moodCounts[moodValue] = (moodCounts[moodValue] ?? 0) + 1;
    }

    return moodCounts.entries.map((entry) {
      final journalWithMood = journals.firstWhere(
        (j) => j.mood.value == entry.key,
      );

      return Mood(
        value: entry.key,
        emoji: journalWithMood.mood.emoji,
        count: entry.value,
      );
    }).toList()
      ..sort((a, b) => b.count.compareTo(a.count)); // Sort by count descending
  }

  void refresh({String? userId}) {
    loadStats(userId: userId);
  }

  @override
  Future<void> close() {
    _journalsSubscription?.cancel();
    return super.close();
  }
}
