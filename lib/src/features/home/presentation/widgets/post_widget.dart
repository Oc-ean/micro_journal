import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:solar_icons/solar_icons.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> tags = ['#achievement', '#fitness', '#motivation'];

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
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Someone ',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                        ),
                        TextSpan(
                          text: 'ㆍ',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                        ),
                        TextSpan(
                          text: '2h ago',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Amazing',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Finally completed my first 5K run today! The feeling of accomplishment is incredible. Small steps really do lead to big achievements. 🏃‍♀️',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 25,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TagContainer(text: tags[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => logman.info('like'),
                child: Row(
                  children: [
                    const Icon(
                      SolarIconsBold.heart,
                      size: 20,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '2',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
              const Text('3 comments'),
            ],
          ),
          const Divider(height: 20, thickness: 0.6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const LikeRowWidget(),
              GestureDetector(
                onTap: () => openCommentsModal(context: context),
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
    List<CommentModel>? comments,
  }) {
    final List<CommentModel> sampleComments = comments ??
        [
          CommentModel(
            user: UserModel(
              username: 'john_doe',
              avatarUrl:
                  'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
            ),
            text: 'This is amazing! Keep up the great work 🔥',
            likes: 12,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            replies: [
              CommentModel(
                user: UserModel(
                  username: 'jane_doe',
                  avatarUrl:
                      'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
                ),
                text: 'Totally agree! So inspiring ✨',
                likes: 3,
                timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              ),
            ],
          ),
          CommentModel(
            user: UserModel(
              username: 'alex_92',
              avatarUrl:
                  'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
            ),
            text: "Love this content! ❤️ Can't wait to see more",
            likes: 8,
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          CommentModel(
            user: UserModel(
              username: 'fitness_guru',
              avatarUrl:
                  'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
            ),
            text: "Congratulations on your 5K! That's a huge milestone 🏃‍♀️",
            likes: 15,
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
        ];

    CommentsModalSheet.show(
      context: context,
      comments: sampleComments,
      onAddComment: (comment) {
        logman.info('New comment: $comment');
      },
      onLikeComment: (comment) {
        logman.info('Liked comment by: ${comment.user.username}');
      },
    );
  }
}
