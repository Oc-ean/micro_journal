import 'package:flutter/material.dart';

import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class PrivacyTile extends StatelessWidget {
  final VoidCallback onDataPrivacyTap;

  const PrivacyTile({
    super.key,
    required this.onDataPrivacyTap,
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
      child: SettingsTile(
        icon: Icons.security_outlined,
        title: 'Data & Privacy',
        subtitle: 'Manage your data and privacy settings',
        trailing: const Icon(Icons.chevron_right),
        onTap: onDataPrivacyTap,
      ),
    );
  }
}
