import 'package:shared_preferences/shared_preferences.dart';

mixin AppPreferences {
  static const String _keyFirstTime = 'is_first_time';
  static const String _fcmToken = 'fcm_token';

  static Future<void> setFirstTime(bool isFirstTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, isFirstTime);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstTime) ?? true;
  }

  static Future<void> setCurrentDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmToken, token);
  }

  static Future<String?> getCurrentDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmToken);
  }
}
