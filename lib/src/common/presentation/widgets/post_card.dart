import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:solar_icons/solar_icons.dart';

class PostCard extends StatelessWidget {
  final JournalModel journal;
  final String currentUserId;
  final VoidCallback? onComment;

  const PostCard({
    super.key,
    required this.journal,
    required this.currentUserId,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border.all(color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (journal.isAnonymous)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.theme.primaryColor,
                  child: Text(
                    journal.user!.username.substring(0, 1),
                    style: context.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                )
              else if (journal.user?.avatarUrl == null)
                CircleAvatar(
                  radius: 20,
                  child: Text(
                    journal.user!.username.substring(0, 1),
                    style: context.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                )
              else
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.theme.primaryColor,
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
                border: Border.all(color: context.theme.dividerColor),
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
              Row(
                children: [
                  const Icon(
                    SolarIconsBold.heart,
                    size: 20,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    (journal.likes?.length ?? 0).toString(),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 15),
                  ),
                ],
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
              LikeRowWidget(
                journalId: journal.id,
                userId: currentUserId,
                isLiked: journal.likes?.contains(currentUserId) ?? false,
              ),
              GestureDetector(
                onTap: () =>
                    openCommentsModal(context: context, journalId: journal.id),
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
    required String journalId,
    List<CommentModel>? comments,
  }) {
    CommentsModalSheet.show(context: context, journalId: journalId);
  }
}
