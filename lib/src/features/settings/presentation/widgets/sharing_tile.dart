import 'package:flutter/material.dart';

import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class SharingTile extends StatelessWidget {
  final bool anonymousSharing;
  final ValueChanged<bool> onAnonymousSharingChanged;
  final VoidCallback onSharingOptionsTap;
  final VoidCallback onExportDataTap;

  const SharingTile({
    super.key,
    required this.anonymousSharing,
    required this.onAnonymousSharingChanged,
    required this.onSharingOptionsTap,
    required this.onExportDataTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Divider(height: 1),
          SettingsTile(
            icon: Icons.download_outlined,
            title: 'Export Data',
            subtitle: 'Download your journal entries',
            trailing: const Icon(Icons.chevron_right),
            onTap: onExportDataTap,
          ),
        ],
      ),
    );
  }
}
