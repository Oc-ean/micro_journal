import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/common/presentation/widgets/follow_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FollowPage extends StatefulWidget {
  final bool isFromNotificationPage;
  final String userId;
  const FollowPage(
      {super.key, required this.userId, this.isFromNotificationPage = false,});

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  late UserDetailsCubit _userDetailsCubit;
  @override
  void initState() {
    super.initState();
    _userDetailsCubit = UserDetailsCubit(
      userRepository: getIt<UserRepository>(),
    );

    _userDetailsCubit.loadUserDetails(widget.userId);
  }

  @override
  void dispose() {
    _userDetailsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackIconButton(),
        title: const Text('Follow'),
      ),
      body: BlocBuilder<UserDetailsCubit, UserDetailsState>(
        bloc: _userDetailsCubit,
        builder: (context, state) {
          final userDetails =
              state is UserDetailsLoaded ? state.user : UserModel.empty();
          final journals = state is UserDetailsLoaded
              ? state.recentPosts
              : [JournalModel.sampleData()];
          return Skeletonizer(
            enabled: state is UserDetailsLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(
                      userDetails.avatarUrl,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    userDetails.username,
                    style: context.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ProfileInfoRow(
                        title: 'Journals',
                        subtitle: userDetails.journals.toString(),
                      ),
                      ProfileInfoRow(
                        title: 'Followers',
                        subtitle: userDetails.followers.length.toString(),
                      ),
                      ProfileInfoRow(
                        title: 'Following',
                        subtitle: userDetails.following.length.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  FollowButton(
                    targetUserId: widget.userId,
                    isFromNotificationPage: widget.isFromNotificationPage,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Recent Journals',
                    style: context.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: journals.length,
                    itemBuilder: (context, index) {
                      final journal = journals[index];
                      return GestureDetector(
                        onTap: () => context.push(
                          Routes.follow.path,
                          extra: {
                            'userId': journal.user!.id,
                          },
                        ),
                        child: PostCard(
                          journal: journal,
                          currentUserId:
                              getIt<AuthRepository>().currentUser!.uid,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
