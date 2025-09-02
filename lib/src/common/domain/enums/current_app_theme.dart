import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';

enum CurrentAppTheme {
  system(systemAdaptive, ThemeMode.system),
  light(lightMode, ThemeMode.light),
  dark(darkMode, ThemeMode.dark);

  final String name;
  final ThemeMode themeMode;
  const CurrentAppTheme(this.name, this.themeMode);
}
