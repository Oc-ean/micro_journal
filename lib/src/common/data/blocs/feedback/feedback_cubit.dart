import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

part 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final FeedbackService _feedbackService;

  FeedbackCubit({
    required FeedbackService feedbackService,
  })  : _feedbackService = feedbackService,
        super(
          FeedbackInitial(),
        );

  Future<void> submitFeedback(
    BuildContext context,
    String text,
    Uint8List screenshot,
  ) async {
    emit(FeedbackLoading());
    try {
      final feedback =
          FeedbackDetails(feedbackText: text, screenshot: screenshot);

      await _feedbackService.sendEmailFeedback(context, feedback);

      emit(FeedbackSuccess());
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }
}
