import 'package:micro_journal/src/common/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentAppThemeService {
  const CurrentAppThemeService();

  Future<void> setCurrentAppTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeNameKey, themeName);
  }

  Future<CurrentAppTheme> getCurrentAppTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(themeNameKey) ?? 'system';

    switch (themeName) {
      case darkMode:
        return CurrentAppTheme.dark;
      case lightMode:
        return CurrentAppTheme.light;
      default:
        return CurrentAppTheme.system;
    }
  }
}
