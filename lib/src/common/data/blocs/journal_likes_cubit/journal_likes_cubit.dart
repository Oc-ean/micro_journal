import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'journal_likes_state.dart';

class JournalLikesCubit extends Cubit<JournalLikesState> {
  final JournalRepository _repository;

  JournalLikesCubit(this._repository) : super(JournalLikesInitial());

  Future<void> likeJournal(String journalId, String userId) async {
    try {
      emit(JournalLikesLoading(journalId));
      await _repository.likeJournal(journalId, userId);
      emit(JournalLikesSuccess(journalId, true));
    } catch (e) {
      emit(JournalLikesError(e.toString()));
    }
  }

  Future<void> unlikeJournal(String journalId, String userId) async {
    try {
      await _repository.unlikeJournal(journalId, userId);
    } catch (e) {
      emit(JournalLikesError(e.toString()));
    }
  }

  Future<bool> isJournalLiked(String journalId, String userId) async {
    return await _repository.isJournalLiked(journalId, userId);
  }
}
