import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarJournalPage extends StatefulWidget {
  const CalendarJournalPage({super.key});

  @override
  State<CalendarJournalPage> createState() => _CalendarJournalPageState();
}

class _CalendarJournalPageState extends State<CalendarJournalPage> {
  late DateTime _focusedDay;
  late AuthRepository _authRepository;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();

    _authRepository = getIt<AuthRepository>();
    final userId = _authRepository.currentUser?.uid;
    getIt<CalendarCubit>().loadMonthJournals(_focusedDay, userId!);
  }

  JournalModel? _getJournalForDay(List<JournalModel> journals, DateTime day) {
    try {
      return journals.firstWhere(
        (journal) => isSameDay(journal.createdAt, day),
      );
    } catch (e) {
      return null;
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    getIt<CalendarCubit>()
        .updateSelectedDate(selectedDay, _authRepository.currentUser!.uid);
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });

    getIt<CalendarCubit>()
        .loadMonthJournals(focusedDay, _authRepository.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Calendar'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              final today = DateTime.now();
              getIt<CalendarCubit>()
                  .updateSelectedDate(today, _authRepository.currentUser!.uid);
              setState(() {
                _focusedDay = today;
              });
              getIt<CalendarCubit>()
                  .loadMonthJournals(today, _authRepository.currentUser!.uid);
            },
          ),
        ],
      ),
      body: BlocBuilder<CalendarCubit, CalendarState>(
        bloc: getIt<CalendarCubit>(),
        builder: (context, state) {
          final selectedDate =
              state is CalendarLoaded ? state.selectedDate : DateTime.now();
          final journals = state is CalendarLoaded
              ? state.journals
              : List.generate(2, (index) => JournalModel.sampleData());
          final selectedJournal = _getJournalForDay(journals, selectedDate);
          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  border: Border.all(color: context.theme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Skeletonizer(
                  enabled: state is CalendarLoading,
                  child: TableCalendar<JournalModel>(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      final isSelected = isSameDay(selectedDate, day);
                      if (day.day <= 3) {}
                      return isSelected;
                    },
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
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
                        selectedDay: selectedDate,
                        journal: _getJournalForDay(journals, day),
                      ),
                      selectedBuilder: (context, day, focusedDay) =>
                          CalendarJournalCell(
                        day: day,
                        focusedDay: focusedDay,
                        selectedDay: selectedDate,
                        journal: _getJournalForDay(journals, day),
                      ),
                      todayBuilder: (context, day, focusedDay) =>
                          CalendarJournalCell(
                        day: day,
                        focusedDay: focusedDay,
                        selectedDay: selectedDate,
                        journal: _getJournalForDay(journals, day),
                      ),
                    ),
                    onDaySelected: _onDaySelected,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: _onPageChanged,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      formatDate(selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (selectedJournal != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedJournal.mood.emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              selectedJournal.mood.value
                                      .substring(0, 1)
                                      .toUpperCase() +
                                  selectedJournal.mood.value.substring(1),
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
                        selectedDay: selectedDate,
                      ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
