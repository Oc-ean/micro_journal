import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';

class AlreadyJournaledTodayWidget extends StatelessWidget {
  const AlreadyJournaledTodayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: Colors.green[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Journal Complete! ✨',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You've already shared your thoughts today",
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Come back tomorrow for another reflection',
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
