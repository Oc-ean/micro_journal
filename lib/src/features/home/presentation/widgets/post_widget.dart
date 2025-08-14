import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:solar_icons/solar_icons.dart';

class PostWidget extends StatelessWidget {
  final JournalModel journal;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const PostWidget({
    super.key,
    required this.journal,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(journal.user!.avatarUrl),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${journal.user!.username} ',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                          ),
                          TextSpan(
                            text: 'ㆍ',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                          ),
                          TextSpan(
                            text: journal.timeAgo,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            journal.mood.emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            journal.mood.value.substring(0, 1).toUpperCase() +
                                journal.mood.value.substring(1),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              journal.thoughts,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),

          if (journal.intention != null && journal.intention!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Today's intention:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    journal.intention!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Tags List
          if (journal.hashTags.isNotEmpty)
            SizedBox(
              height: 25,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: journal.hashTags.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TagContainer(text: journal.hashTags[index]),
                  );
                },
              ),
            ),

          const SizedBox(height: 10),

          // Like and Comment Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    const Icon(
                      SolarIconsBold.heart,
                      size: 20,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      journal.likesCount.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Text(
                '${journal.commentsCount} ${journal.commentsCount == 1 ? 'comment' : 'comments'}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),

          const Divider(height: 20, thickness: 0.6),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const LikeRowWidget(),
              GestureDetector(
                onTap: () =>
                    openCommentsModal(context: context, journal: journal),
                child: const CommentRowWidget(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void openCommentsModal({
    required BuildContext context,
    required JournalModel journal,
    List<CommentModel>? comments,
  }) {
    final List<CommentModel> sampleComments = comments ??
        [
          CommentModel(
            id: 'c1',
            journalId: journal.id,
            content: 'This is amazing! Keep up the great work 🔥',
            user: UserModel(
              id: '8',
              email: 'jg4t4@example.com',
              username: 'john_doe',
              avatarUrl:
                  'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
            ),
            isAnonymous: false,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
            parentCommentId: null,
            likes: ['2', '4', '6', '10', '12'], // mock user IDs
          ),
          CommentModel(
            id: 'c2',
            journalId: journal.id,
            content: 'Totally agree! So inspiring ✨',
            user: UserModel(
              id: '6',
              email: 'jg4t4@example.com',
              username: 'jane_doe',
              avatarUrl:
                  'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
            ),
            isAnonymous: false,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
            parentCommentId: 'c1',
            // reply to comment c1
            likes: ['3', '5', '7'],
          ),
          CommentModel(
            id: 'c3',
            journalId: journal.id,
            content: "Love this content! ❤️ Can't wait to see more",
            user: UserModel(
              id: '2',
              email: 'jg4t4@example.com',
              username: 'alex_92',
              avatarUrl:
                  'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
            ),
            isAnonymous: false,
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
            updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
            parentCommentId: null,
            likes: ['6', '1', '3', '4', '8', '9', '10', '11'],
          ),
          CommentModel(
            id: 'c4',
            journalId: journal.id,
            content: "Congratulations! That's a huge milestone 🏃‍♀️",
            user: UserModel(
              id: '3',
              email: 'jg4t4@example.com',
              username: 'fitness_guru',
              avatarUrl:
                  'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
            ),
            isAnonymous: false,
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
            updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
            parentCommentId: null,
            likes: [
              '1',
              '4',
              '5',
              '9',
              '10',
              '11',
              '12',
              '13',
              '14',
              '15',
              '16',
              '17',
              '18',
              '19',
              '20'
            ],
          ),
        ];

    CommentsModalSheet.show(
      context: context,
      comments: sampleComments,
      onAddComment: (comment) {
        logman.info('New comment on journal ${journal.id}: $comment');
      },
      onLikeComment: (comment) {
        logman.info(
          'Liked comment by: ${comment.user?.username ?? 'anonymous'} on journal ${journal.id}',
        );
      },
    );
  }
}
