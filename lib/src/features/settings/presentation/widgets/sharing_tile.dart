import 'package:flutter/material.dart';

import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class SharingTile extends StatelessWidget {
  final bool anonymousSharing;
  final ValueChanged<bool> onAnonymousSharingChanged;
  final VoidCallback onSharingOptionsTap;

  const SharingTile({
    super.key,
    required this.anonymousSharing,
    required this.onAnonymousSharingChanged,
    required this.onSharingOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border.all(color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.person_off_outlined,
            title: 'Anonymous Sharing',
            subtitle: 'Share entries without showing your identity',
            trailing: Switch(
              value: anonymousSharing,
              onChanged: onAnonymousSharingChanged,
            ),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: Icons.share_outlined,
            title: 'Default Sharing',
            subtitle: 'Set default privacy for new entries',
            trailing: const Icon(Icons.chevron_right),
            onTap: onSharingOptionsTap,
          ),
        ],
      ),
    );
  }
}
