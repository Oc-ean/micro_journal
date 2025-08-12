import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:solar_icons/solar_icons.dart';

class NotificationTile extends StatelessWidget {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onEmailNotificationsChanged;

  const NotificationTile({
    super.key,
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.onNotificationsChanged,
    required this.onEmailNotificationsChanged,
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
            icon: SolarIconsOutline.bell,
            title: 'Push Notifications',
            subtitle: 'Receive notifications on your device',
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
            ),
          ),
          const Divider(height: 1),
          SettingsTile(
            icon: SolarIconsOutline.mailbox,
            title: 'Email Notifications',
            subtitle: 'Get updates via email',
            trailing: Switch(
              value: emailNotifications,
              onChanged: onEmailNotificationsChanged,
            ),
          ),
        ],
      ),
    );
  }
}
