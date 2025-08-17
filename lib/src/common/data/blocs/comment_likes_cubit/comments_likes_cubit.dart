import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'comments_likes_state.dart';

class CommentLikesCubit extends Cubit<CommentLikesState> {
  final JournalRepository _repository;

  CommentLikesCubit(this._repository) : super(CommentLikesInitial());

  Future<void> likeComment(String journalId, String userId) async {
    try {
      emit(CommentLikesLoading());
      await _repository.likeComment(journalId, userId);
      emit(const CommentLikesSuccess());
    } catch (e) {
      emit(CommentLikesError(e.toString()));
    }
  }

  Future<void> unlikeComment(String journalId, String userId) async {
    try {
      emit(CommentLikesLoading());
      await _repository.unlikeComment(journalId, userId);
      emit(const CommentLikesSuccess());
    } catch (e) {
      emit(CommentLikesError(e.toString()));
    }
  }
}
