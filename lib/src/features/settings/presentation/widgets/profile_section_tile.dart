import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class ProfileSectionTile extends StatefulWidget {
  final VoidCallback onEditProfile;

  const ProfileSectionTile({
    super.key,
    required this.onEditProfile,
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

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user.username,
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onEditProfile,
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
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
        );
      },
    );
  }
}
