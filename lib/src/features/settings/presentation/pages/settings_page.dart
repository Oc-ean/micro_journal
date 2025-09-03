import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool emailNotifications = false;
  bool anonymousSharing = false;
  bool dataSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ProfileSectionTile(
              onEditProfile: _navigateToEditProfile,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Notifications'),
            NotificationTile(
              notificationsEnabled: notificationsEnabled,
              emailNotifications: emailNotifications,
              onNotificationsChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Privacy & Security'),
            PrivacyTile(
              onDataPrivacyTap: _navigateToDataPrivacy,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Sharing & Content'),
            SharingTile(
              anonymousSharing: anonymousSharing,
              onAnonymousSharingChanged: (value) {
                setState(() {
                  anonymousSharing = value;
                });
                _showAnonymousDialog(value);
              },
              onSharingOptionsTap: _showSharingOptions,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Support'),
            SupportTile(
              onHelpTap: _navigateToHelp,
              onFeedbackTap: _sendFeedback,
              onAboutTap: _showAbout,
              onSignOutTap: _signOut,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: context.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  void _navigateToEditProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Navigate to Edit Profile',
          style: TextStyle(color: context.theme.textTheme.bodySmall!.color),
        ),
      ),
    );
  }

  void _navigateToDataPrivacy() {
    context.showSnackBarUsingText('Navigate to Data & Privacy');
  }

  void _navigateToHelp() {
    context.showSnackBarUsingText('Navigate to Help Center');
  }

  void _showSharingOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Default Sharing Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Private'),
              subtitle: const Text('Only visible to you'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Followers Only'),
              subtitle: const Text('Visible to your followers'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Public'),
              subtitle: const Text('Visible to everyone'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnonymousDialog(bool enabled) {
    if (enabled) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Anonymous Sharing'),
          content: const Text(
            'When anonymous sharing is enabled, your name and profile picture will not be shown when you share entries publicly.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    }
  }

  void _sendFeedback() {
    context.showSnackBarUsingText('Opening feedback form...');
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Micro Journal'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A simple and beautiful journaling app to capture your thoughts and memories.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.showSnackBarUsingText('Signed out successfully');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
