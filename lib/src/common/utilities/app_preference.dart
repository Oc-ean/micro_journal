import 'package:shared_preferences/shared_preferences.dart';

mixin AppPreferences {
  static const String _keyFirstTime = 'is_first_time';

  static Future<void> setFirstTime(bool isFirstTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, isFirstTime);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstTime) ?? true;
  }
}
