import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

import 'package:solar_icons/solar_icons.dart';

class OverviewTab extends StatelessWidget {
  final JournalStats stats;
  const OverviewTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                icon: SolarIconsBold.document,
                title: 'Total Entries',
                value: stats.totalEntries.toString(),
                color: Colors.blue,
              ),
              StatCard(
                icon: SolarIconsBold.fire,
                title: 'Current Streak',
                value: '${stats.currentStreak} days',
                color: Colors.orange,
              ),
              StatCard(
                icon: SolarIconsBold.heart,
                title: 'Most Frequent Mood',
                value: stats.mostFrequentMood.emoji,
                color: Colors.red,
              ),
              StatCard(
                icon: SolarIconsBold.chatRound,
                title: 'Avg Words / Entry',
                value: stats.averageWordsPerEntry.toString(),
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Writing Stats', context),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MetricItem(
                        title: 'Total Words',
                        value: stats.totalWords.toString(),
                        icon: Icons.text_fields,
                      ),
                    ),
                    Expanded(
                      child: MetricItem(
                        title: 'Avg per Entry',
                        value: stats.averageWordsPerEntry.toString(),
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Most Frequent Mood', context),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      stats.mostFrequentMood.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      stats.mostFrequentMood.value,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  Text _sectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
