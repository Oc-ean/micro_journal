import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentAppThemeCubit, CurrentAppTheme>(
      bloc: getIt<CurrentAppThemeCubit>(),
      builder: (context, theme) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'Miro Journal',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: theme.themeMode,
        );
      },
    );
  }
}
