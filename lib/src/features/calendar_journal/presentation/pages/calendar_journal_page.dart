import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarJournalPage extends StatefulWidget {
  const CalendarJournalPage({super.key});

  @override
  State<CalendarJournalPage> createState() => _CalendarJournalPageState();
}

class _CalendarJournalPageState extends State<CalendarJournalPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  late Map<DateTime, JournalModel> _journalEntries;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDay = DateTime(today.year, today.month, today.day);
    _focusedDay = today;

    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    _journalEntries = {
      DateTime(now.year, now.month, now.day): JournalModel(
        id: '1',
        date: now,
        mood: 'happy',
        moodEmoji: '😊',
        thoughts:
            'Had a great day today! Accomplished all my goals and felt really productive.',
        intention: 'Focus on maintaining this positive energy',
        tags: ['gratitude', 'goals', 'win'],
        likesCount: 12,
        commentsCount: 5,
        user: UserModel(
          id: '1',
          username: 'john_fitness',
          avatarUrl:
              'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
        ),
      ),
      DateTime(now.year, now.month, now.day - 1): JournalModel(
        id: '2',
        date: now.subtract(const Duration(days: 1)),
        mood: 'okay',
        moodEmoji: '😐',
        thoughts:
            'It was an average day. Had some challenges at work but managed to push through.',
        intention: 'Be more patient with difficult situations',
        tags: ['work', 'stress', 'reflection'],
        likesCount: 3,
        commentsCount: 2,
        user: UserModel(
          id: '2',
          username: 'jane_fitness',
          avatarUrl:
              'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
        ),
      ),
      DateTime(now.year, now.month, now.day - 3): JournalModel(
        id: '3',
        date: now.subtract(const Duration(days: 3)),
        mood: 'amazing',
        moodEmoji: '🤩',
        thoughts:
            'What an incredible day! Got promoted at work and celebrated with family.',
        intention: 'Stay humble and continue growing',
        tags: ['work', 'family', 'win', 'gratitude'],
        likesCount: 25,
        commentsCount: 8,
        user: UserModel(
          id: '3',
          username: 'jane_fitness',
          avatarUrl:
              'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
        ),
      ),
      DateTime(now.year, now.month, now.day - 5): JournalModel(
        id: '4',
        date: now.subtract(const Duration(days: 5)),
        mood: 'sad',
        moodEmoji: '😢',
        thoughts:
            'Feeling a bit down today. Missing some friends and dealing with personal stuff.',
        intention: 'Reach out to loved ones for support',
        tags: ['reflection', 'family', 'health'],
        likesCount: 7,
        commentsCount: 12,
        user: UserModel(
          id: '4',
          username: 'jane_fitness',
          avatarUrl:
              'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
        ),
      ),
      DateTime(now.year, now.month, now.day - 7): JournalModel(
        id: '5',
        date: now.subtract(const Duration(days: 7)),
        mood: 'happy',
        moodEmoji: '😊',
        thoughts:
            'Great weekend with friends. Went hiking and had meaningful conversations.',
        tags: ['love', 'health', 'gratitude'],
        likesCount: 15,
        commentsCount: 4,
        user: UserModel(
          id: '5',
          username: 'jane_fitness',
          avatarUrl:
              'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
        ),
      ),
    };
  }

  JournalModel? _getJournalForDay(DateTime day) {
    return _journalEntries[DateTime(day.year, day.month, day.day)];
  }

  List<JournalModel> _getJournalsForMonth(DateTime month) {
    return _journalEntries.values
        .where(
          (journal) =>
              journal.date.year == month.year &&
              journal.date.month == month.month,
        )
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedJournal = _getJournalForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Calendar'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                final today = DateTime.now();
                _selectedDay = DateTime(today.year, today.month, today.day);
                _focusedDay = today;
              });
            },
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar<JournalModel>(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red[400]),
                holidayTextStyle: TextStyle(color: Colors.red[400]),
                defaultTextStyle: const TextStyle(fontSize: 16),
                selectedTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: context.theme.primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) =>
                    CalendarJournalCell(
                  day: day,
                  focusedDay: focusedDay,
                  selectedDay: _selectedDay,
                  journal: _getJournalForDay(day),
                ),
                selectedBuilder: (context, day, focusedDay) =>
                    CalendarJournalCell(
                  day: day,
                  focusedDay: focusedDay,
                  selectedDay: _selectedDay,
                  journal: _getJournalForDay(day),
                ),
                todayBuilder: (context, day, focusedDay) => CalendarJournalCell(
                  day: day,
                  focusedDay: focusedDay,
                  selectedDay: _selectedDay,
                  journal: _getJournalForDay(day),
                ),
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  _formatDate(_selectedDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (selectedJournal != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedJournal.moodEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          selectedJournal.mood.substring(0, 1).toUpperCase() +
                              selectedJournal.mood.substring(1),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: selectedJournal != null
                ? CalendarJournalPost(journal: selectedJournal)
                : NoJournalEntry(
                    selectedDay: _selectedDay,
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
