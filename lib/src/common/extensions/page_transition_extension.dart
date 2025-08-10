import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_platform/universal_platform.dart';

extension PageTransition on Widget {
  Page<dynamic> pageTransition({required GoRouterState state}) {
    if (UniversalPlatform.isWeb || UniversalPlatform.isMacOS) {
      return CustomTransitionPage(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        child: this,
        name: state.name,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
            child: child,
          );
        },
      );
    } else {
      return MaterialPage<void>(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        name: state.name,
        child: this,
      );
    }
  }
}
