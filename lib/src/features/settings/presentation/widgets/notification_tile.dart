import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:solar_icons/solar_icons.dart';

class NotificationTile extends StatelessWidget {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final ValueChanged<bool> onNotificationsChanged;

  const NotificationTile({
    super.key,
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.onNotificationsChanged,
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
            icon: SolarIconsOutline.bell,
            title: 'Push Notifications',
            subtitle: 'Receive notifications on your device',
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
            ),
          ),
        ],
      ),
    );
  }
}
