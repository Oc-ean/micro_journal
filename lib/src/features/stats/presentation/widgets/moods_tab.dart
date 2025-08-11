import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class MoodsTab extends StatelessWidget {
  final JournalStats stats;

  const MoodsTab({
    super.key,
    required this.stats,
  });

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'amazing':
        return Colors.purple;
      case 'happy':
        return Colors.green;
      case 'okay':
        return Colors.orange;
      case 'sad':
        return Colors.blue;
      case 'terrible':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = stats.moods.fold<int>(0, (sum, mood) => sum + (mood.count));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Mood Distribution'),
            const SizedBox(height: 20),
            ...stats.moods.map((mood) {
              final count = mood.count;
              final percentage = total > 0 ? (count / total * 100).round() : 0;
              return MoodBar(
                mood: mood.value,
                count: count,
                percentage: percentage,
                color: _getMoodColor(mood.value),
              );
            }),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Text _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
