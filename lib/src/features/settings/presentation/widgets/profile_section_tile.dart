import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileSectionTile extends StatefulWidget {
  const ProfileSectionTile({
    super.key,
  });

  @override
  State<ProfileSectionTile> createState() => _ProfileSectionTileState();
}

class _ProfileSectionTileState extends State<ProfileSectionTile> {
  late UserProfileCubit _userProfileCubit;

  @override
  void initState() {
    super.initState();
    _userProfileCubit = getIt<UserProfileCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      bloc: _userProfileCubit,
      builder: (context, state) {
        final user =
            state is UserProfileLoaded ? state.user : UserModel.empty();

        return Skeletonizer(
          enabled: state is UserProfileLoading,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              border: Border.all(color: context.theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: user.avatarUrl.isNotEmpty
                      ? ClipOval(
                          child: CustomImage(
                            imagePath: user.avatarUrl,
                            height: 80,
                            width: 80,
                          ),
                        )
                      : Center(
                          child: Text(
                            user.username,
                            style: context.theme.textTheme.titleLarge,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: context.theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ProfileInfoRow(
                            title: 'Journals',
                            subtitle: user.journals.toString(),
                          ),
                          ProfileInfoRow(
                            title: 'Followers',
                            subtitle: user.followers.length.toString(),
                          ),
                          ProfileInfoRow(
                            title: 'Following',
                            subtitle: user.following.length.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
