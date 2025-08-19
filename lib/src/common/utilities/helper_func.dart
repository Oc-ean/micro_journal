import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';

Exception handleFirebaseAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'account-exists-with-different-credential':
      return Exception('An account already exists with a different credential');
    case 'invalid-credential':
      return Exception('The credential is invalid or expired');
    case 'operation-not-allowed':
      return Exception('Google sign-in is not enabled');
    case 'user-disabled':
      return Exception('This user account has been disabled');
    case 'user-not-found':
      return Exception('No user found with this credential');
    case 'wrong-password':
      return Exception('Wrong password provided');
    case 'invalid-verification-code':
      return Exception('Invalid verification code');
    case 'invalid-verification-id':
      return Exception('Invalid verification ID');
    default:
      return Exception('Authentication failed: ${e.message}');
  }
}

String generateAnonymousUsername() {
  final adjectives = [
    'Peaceful',
    'Thoughtful',
    'Gentle',
    'Wise',
    'Kind',
    'Brave',
    'Creative',
    'Calm',
    'Bright',
    'Happy',
  ];
  final nouns = [
    'Writer',
    'Dreamer',
    'Thinker',
    'Soul',
    'Heart',
    'Mind',
    'Spirit',
    'Wanderer',
    'Seeker',
    'Friend',
  ];

  final random = DateTime.now().millisecond;
  final adjective = adjectives[random % adjectives.length];
  final noun = nouns[(random ~/ 10) % nouns.length];
  final number = (random % 100).toString().padLeft(2, '0');

  return '$adjective$noun$number';
}

bool hasJournalToday(List<JournalModel> journals) {
  final currentUser = getIt<AuthRepository>().currentUser;
  if (currentUser == null) return true;

  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  return journals.any((journal) {
    final journalDate = journal.createdAt;
    final isToday =
        journalDate.isAfter(todayStart) && journalDate.isBefore(todayEnd);

    if (journal.isAnonymous) {
      return false;
    } else {
      return isToday && journal.user?.id == currentUser.uid;
    }
  });
}

String formatDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String getTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays > 0) {
    return '${difference.inDays}d';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  } else {
    return 'now';
  }
}

void showNoInternetPopup(BuildContext context) {
  if (ModalRoute.of(context)?.isCurrent != true) return;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => NoInternetPopup(
      onRetry: () async {
        final cubit = getIt<InternetCubit>();
        final success = await cubit.checkAgain();

        if (!success) {
          context.showSnackBar(
            const SnackBar(
              content: Text('Still no internet connection'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          router.pop();
        }
      },
    ),
  );
}
