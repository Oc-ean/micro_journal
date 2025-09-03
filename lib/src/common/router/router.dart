import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logman/logman.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

part 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKeyHome = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorKeyStats = GlobalKey<NavigatorState>(debugLabel: 'stats');
final _shellNavigatorKeyCalendar =
    GlobalKey<NavigatorState>(debugLabel: 'calendar_journal');
final _shellNavigatorKeySettings = GlobalKey<NavigatorState>(
  debugLabel: 'settings',
);

final router = GoRouter(
  initialLocation: Routes.splash.path,
  navigatorKey: _rootNavigatorKey,
  observers: [
    LogmanNavigatorObserver(),
  ],
  routes: [
    GoRoute(
      path: Routes.splash.path,
      name: Routes.splash.name,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: Routes.onboarding.path,
      name: Routes.onboarding.name,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: Routes.login.path,
      name: Routes.login.name,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.create.path,
      name: Routes.create.name,
      builder: (context, state) => const CreateJournalPage(),
    ),
    GoRoute(
      path: Routes.notification.path,
      name: Routes.notification.name,
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      path: Routes.follow.path,
      name: Routes.follow.name,
      builder: (context, state) {
        final extra = state.extra as Map<dynamic, dynamic>? ?? {};
        final userId = extra['userId'] as String? ?? '';
        final isFromNotificationPage =
            extra['isFromNotificationPage'] as bool? ?? false;
        return FollowPage(
          userId: userId,
          isFromNotificationPage: isFromNotificationPage,
        );
      },
    ),
    GoRoute(
      path: Routes.notificationDetails.path,
      name: Routes.notificationDetails.name,
      builder: (context, state) {
        final extra = state.extra as Map<dynamic, dynamic>? ?? {};

        final postId = extra['postId'] as String? ?? '';
        final commentId = extra['commentId'] as String? ?? '';
        final notificationType = extra['notificationType'] as String? ?? '';

        return JournalNotificationDetailPage(
          postId: postId,
          commentId: commentId,
          notificationType: notificationType,
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, navigationShell) {
        return RootPage(
          statefulNavigationShell: navigationShell,
        ).pageTransition(state: state);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeyHome,
          observers: [
            LogmanNavigatorObserver(),
          ],
          routes: [
            GoRoute(
              path: Routes.home.path,
              name: Routes.home.name,
              pageBuilder: (context, state) {
                return const HomePage().pageTransition(state: state);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeyCalendar,
          observers: [
            LogmanNavigatorObserver(),
          ],
          routes: [
            GoRoute(
              path: Routes.calendar.path,
              name: Routes.calendar.name,
              pageBuilder: (context, state) {
                return const CalendarJournalPage().pageTransition(state: state);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeyStats,
          observers: [
            LogmanNavigatorObserver(),
          ],
          routes: [
            GoRoute(
              path: Routes.stats.path,
              name: Routes.stats.name,
              pageBuilder: (context, state) {
                return const StatsPage().pageTransition(state: state);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeySettings,
          observers: [
            LogmanNavigatorObserver(),
          ],
          routes: [
            GoRoute(
              path: Routes.settings.path,
              name: Routes.settings.name,
              pageBuilder: (context, state) {
                return const SettingsPage().pageTransition(state: state);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
