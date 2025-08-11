import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      // routerDelegate: router.routerDelegate,
      title: 'Pronto',
      theme: lightTheme,
    );
  }
}
