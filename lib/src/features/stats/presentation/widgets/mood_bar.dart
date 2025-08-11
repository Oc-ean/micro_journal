import 'package:flutter/material.dart';

class MoodBar extends StatelessWidget {
  final String mood;
  final int count;
  final int percentage;
  final Color color;

  const MoodBar({
    super.key,
    required this.mood,
    required this.count,
    required this.percentage,
    required this.color,
  });

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'amazing':
        return '🤩';
      case 'happy':
        return '😊';
      case 'okay':
        return '😐';
      case 'sad':
        return '😢';
      case 'terrible':
        return '😭';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getMoodEmoji(mood)),
              const SizedBox(width: 8),
              Text(
                mood.substring(0, 1).toUpperCase() + mood.substring(1),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '$count entries ($percentage%)',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
