import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static Future<String?> getUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('user_id');
  }

  static Future<void> setUserId(String userId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('user_id', userId);
  }

  static Future<void> clearUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('user_id');
  }
}
