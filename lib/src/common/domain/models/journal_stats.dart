import 'package:micro_journal/src/common/common.dart';

class JournalStats {
  final int totalEntries;
  final int currentStreak;
  final int totalWords;
  final List<Mood> moods;

  const JournalStats({
    required this.totalEntries,
    required this.currentStreak,
    required this.totalWords,
    required this.moods,
  });

  int get averageWordsPerEntry =>
      totalEntries > 0 ? totalWords ~/ totalEntries : 0;

  Mood get mostFrequentMood {
    if (moods.isEmpty) return Mood(value: 'neutral', emoji: '😐');
    return moods.reduce((a, b) => a.count > b.count ? a : b);
  }

  static JournalStats get mockData => JournalStats(
        totalEntries: 24,
        currentStreak: 5,
        totalWords: 6800,
        moods: [
          Mood(value: 'amazing', emoji: '🤩', count: 6),
          Mood(value: 'happy', emoji: '😊', count: 10),
          Mood(value: 'okay', emoji: '😐', count: 5),
          Mood(value: 'sad', emoji: '😢', count: 2),
          Mood(value: 'terrible', emoji: '😭', count: 1),
        ],
      );

  factory JournalStats.fromJson(Map<String, dynamic> json) {
    return JournalStats(
      totalEntries: json['totalEntries'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      totalWords: json['totalWords'] as int? ?? 0,
      moods: (json['moods'] as List<dynamic>? ?? [])
          .map((e) => Mood.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'currentStreak': currentStreak,
      'totalWords': totalWords,
      'moods': moods.map((m) => m.toJson()).toList(),
    };
  }

  factory JournalStats.sampleData() => JournalStats.mockData;
}
