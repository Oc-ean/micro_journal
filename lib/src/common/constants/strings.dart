import 'package:micro_journal/src/common/common.dart';

const appName = 'micro_journal';

final sampleJournal = [
  JournalModel(
    id: 'sample_1',
    date: DateTime.now(),
    mood: Mood(value: 'amazing', emoji: '🤩'),
    thoughts:
        'Finally completed my first 5K run today! The feeling of accomplishment is incredible. Small steps really do lead to big achievements. 🏃‍♀️',
    intention:
        'Keep pushing my limits and stay consistent with my fitness goals',
    tags: ['achievement', 'fitness', 'motivation'],
    likesCount: 24,
    commentsCount: 8,
    user: UserModel(
      id: '1',
      email: 'jane_doe@gmail.com',
      username: 'jane_doe',
      avatarUrl:
          'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
    ),
  ),
  JournalModel(
    id: 'sample_2',
    date: DateTime.now(),
    mood: Mood(value: 'excited', emoji: '🤩'),
    thoughts:
        'I just completed my first 5K run! The feeling of accomplishment is incredible. Small steps really do lead to big achievements. 🏃‍♀️',
    intention:
        'Keep pushing my limits and stay consistent with my fitness goals',
    tags: ['achievement', 'fitness', 'motivation'],
    likesCount: 24,
    commentsCount: 8,
    user: UserModel(
      id: '1',
      email: 'jane_doe@gmail.com',
      username: 'jane_doe',
      avatarUrl:
          'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
    ),
  ),
];
