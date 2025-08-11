part of 'router.dart';

enum Routes {
  splash('Splash', '/'),
  home('Home', '/home'),
  onboarding('Onboarding', '/onboarding'),
  stats('Stats', '/stats'),
  calendar('Calendar', '/calendar'),
  settings('Settings', '/settings'),
  login('Login', '/login'),
  create('Create', '/create');

  final String name;
  final String path;

  const Routes(this.name, this.path);
}
