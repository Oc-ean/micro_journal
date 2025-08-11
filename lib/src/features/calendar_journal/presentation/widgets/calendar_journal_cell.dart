import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarJournalCell extends StatelessWidget {
  final DateTime day;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final JournalModel? journal;

  const CalendarJournalCell({
    super.key,
    required this.day,
    required this.focusedDay,
    required this.selectedDay,
    required this.journal,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = isSameDay(selectedDay, day);
    final isToday = isSameDay(DateTime.now(), day);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? Theme.of(context).primaryColor
            : isToday
                ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                : null,
        border: isSelected
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              day.day.toString(),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? Theme.of(context).primaryColor
                        : null,
                fontWeight:
                    isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          if (journal != null)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    journal!.moodEmoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
