import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:table_calendar/table_calendar.dart';

class NoJournalEntry extends StatelessWidget {
  final DateTime selectedDay;

  const NoJournalEntry({
    super.key,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(selectedDay, DateTime.now());
    final isPastDate = selectedDay.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isToday ? Icons.edit : Icons.calendar_today,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isToday
                ? 'No journal entry for today'
                : isPastDate
                    ? 'No journal entry for this day'
                    : 'Cannot create future entries',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isToday
                ? 'Start writing about your day and capture your thoughts'
                : isPastDate
                    ? "You didn't write a journal entry on this day"
                    : 'Journal entries can only be created for today',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (isToday) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push(Routes.create.path),
              icon: const Icon(Icons.add),
              label: const Text("Create Today's Entry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
