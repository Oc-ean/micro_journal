part of 'calendar_cubit.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final List<JournalModel> journals;
  final DateTime selectedDate;

  const CalendarLoaded({
    required this.journals,
    required this.selectedDate,
  });

  CalendarLoaded copyWith({
    List<JournalModel>? journals,
    DateTime? selectedDate,
  }) {
    return CalendarLoaded(
      journals: journals ?? this.journals,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [journals, selectedDate];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
