import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class SupportTile extends StatelessWidget {
  final VoidCallback onHelpTap;
  final VoidCallback onFeedbackTap;
  final VoidCallback onAboutTap;
  final VoidCallback onSignOutTap;

  const SupportTile({
    super.key,
    required this.onHelpTap,
    required this.onFeedbackTap,
    required this.onAboutTap,
    required this.onSignOutTap,
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
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Share your thoughts with us',
            trailing: const Icon(Icons.chevron_right),
            onTap: onFeedbackTap,
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            trailing: const Icon(Icons.chevron_right),
            onTap: onAboutTap,
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            trailing: const Icon(Icons.chevron_right),
            textColor: Colors.red,
            onTap: onSignOutTap,
          ),
        ],
      ),
    );
  }
}
