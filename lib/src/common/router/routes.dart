part of 'router.dart';

enum Routes {
  splash('Splash', '/'),
  home('Home', '/home'),
  onboarding('Onboarding', '/onboarding'),
  stats('Stats', '/stats'),
  calendar('Calendar', '/calendar_journal'),
  settings('Settings', '/settings'),
  login('Login', '/login'),
  notificationDetails('NotificationDetails', '/notification_details'),
  create('Create', '/create');

  final String name;
  final String path;

  const Routes(this.name, this.path);
}
