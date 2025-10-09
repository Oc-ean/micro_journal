import 'dart:typed_data';

class FeedbackDetails {
  final String feedbackText;
  final Uint8List screenshot;

  FeedbackDetails({
    required this.feedbackText,
    required this.screenshot,
  });

  FeedbackDetails copyWith({
    String? feedbackText,
    Uint8List? screenshot,
  }) {
    return FeedbackDetails(
      feedbackText: feedbackText ?? this.feedbackText,
      screenshot: screenshot ?? this.screenshot,
    );
  }
}
