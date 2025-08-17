// features/calendar/cubit/calendar_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final JournalRepository _journalRepository;

  CalendarCubit(this._journalRepository) : super(CalendarInitial());

  Future<void> loadMonthJournals(DateTime month, String userId) async {
    emit(CalendarLoading());
    try {
      final journals =
          await _journalRepository.getJournalsForMonth(month, userId);

      DateTime selectedDate = DateTime.now();
      if (state is CalendarLoaded) {
        selectedDate = (state as CalendarLoaded).selectedDate;
      }

      emit(
        CalendarLoaded(
          journals: journals,
          selectedDate: selectedDate,
        ),
      );
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> updateSelectedDate(DateTime date, String userId) async {
    final journal = await _journalRepository.getJournalsForMonth(date, userId);
    if (state is CalendarLoaded) {
      final currentState = state as CalendarLoaded;
      emit(currentState.copyWith(selectedDate: date, journals: journal));
    }
  }
}
