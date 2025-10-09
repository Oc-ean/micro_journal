import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:path_provider/path_provider.dart';

class FeedbackService {
  Future<String> writeImageToStorage(Uint8List screenshot) async {
    final directory = await getApplicationDocumentsDirectory();
    final screenshotFilePath = '${directory.path}/feedback_screenshot.png';
    final file = File(screenshotFilePath);
    await file.writeAsBytes(screenshot);
    return screenshotFilePath;
  }

  Future<void> sendEmailFeedback(
    BuildContext context,
    FeedbackDetails feedback,
  ) async {
    const subject = 'App Feedback Subject';

    try {
      final screenshotFilePath = await writeImageToStorage(feedback.screenshot);

      final Email email = Email(
        body: feedback.feedbackText,
        subject: subject,
        recipients: [dotenv.env['FEEDBACK_EMAIL']!],
        attachmentPaths: [screenshotFilePath],
      );

      await FlutterEmailSender.send(email);
    } catch (e) {
      throw Exception('Failed to send feedback: $e');
    }
  }
}
