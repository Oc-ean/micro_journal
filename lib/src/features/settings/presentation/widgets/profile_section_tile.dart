import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class ProfileSectionTile extends StatelessWidget {
  final VoidCallback onEditProfile;

  const ProfileSectionTile({
    super.key,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
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
            child: const ClipOval(
              child: CustomImage(
                imagePath:
                    'https://images.pexels.com/photos/1321942/pexels-photo-1321942.jpeg',
                height: 80,
                width: 80,
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
                      'Micheal',
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: onEditProfile,
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                Text(
                  'micheal@gmail.com',
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ProfileInfoRow(
                      title: 'Journals',
                      subtitle: '21',
                    ),
                    ProfileInfoRow(
                      title: 'Followers',
                      subtitle: '1',
                    ),
                    ProfileInfoRow(
                      title: 'Following',
                      subtitle: '1',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
