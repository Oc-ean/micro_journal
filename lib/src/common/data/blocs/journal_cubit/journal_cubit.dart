import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalRepository _repository;
  StreamSubscription<dynamic>? _journalsSubscription;

  JournalCubit(this._repository) : super(JournalInitial()) {
    loadJournals();
    ConnectionManager().registerCubit<JournalCubit>(_reconnect);
  }

  void _reconnect() {
    logman.info('JournalCubit reconnecting...');

    if (state is JournalLoaded || state is JournalError) {
      logman.info('Reloading journals after reconnection');
      loadJournals();
    }
  }

  void loadJournals() {
    emit(JournalLoading());
    _journalsSubscription?.cancel();
    _journalsSubscription = _repository.getJournals().listen(
      (journals) {
        emit(JournalLoaded(journals: journals));
      },
      onError: (Object error) {
        logman.error('Error loading journals: $error.toString()');
        emit(JournalError(error.toString()));
      },
    );
  }

  Future<void> createJournal(JournalModel journal) async {
    try {
      emit(JournalCreating());
      await _repository.createJournal(journal);
      emit(JournalCreated(journal));
    } catch (e) {
      logman.error('Failed to create journal: $e.');
      emit(JournalError('Failed to create journal: $e.'));
    }
  }

  Future<void> updateJournal(JournalModel journal) async {
    try {
      await _repository
          .updateJournal(journal.copyWith(updatedAt: DateTime.now()));
    } catch (e) {
      emit(JournalError('Failed to update journal: $e'));
    }
  }

  Future<void> deleteJournal(String id) async {
    try {
      await _repository.deleteJournal(id);
    } catch (e) {
      emit(JournalError('Failed to delete journal: $e'));
    }
  }

  @override
  Future<void> close() {
    _journalsSubscription?.cancel();
    return super.close();
  }
}
