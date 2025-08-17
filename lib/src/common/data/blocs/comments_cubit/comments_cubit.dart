import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final JournalRepository _repository;
  StreamSubscription<dynamic>? _commentsSubscription;

  CommentsCubit(this._repository) : super(CommentsInitial());

  void loadComments(String journalId) {
    emit(CommentsLoading());
    _commentsSubscription?.cancel();
    _commentsSubscription = _repository.getComments(journalId).listen(
      (comments) {
        emit(CommentsLoaded(comments));
      },
      onError: (Object error) {
        emit(CommentsError(error.toString()));
      },
    );
  }

  Future<void> addComment(CommentModel comment) async {
    try {
      await _repository.addComment(comment);
    } catch (e) {
      emit(CommentsError('Failed to add comment: $e'));
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(commentId);
    } catch (e) {
      emit(CommentsError('Failed to delete comment: $e'));
    }
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }
}
