import 'package:shared_preferences/shared_preferences.dart';

class AppUtility {
  static String? id;
  static String? empID;
  static String? name;
  static String? token;
  // static String? userId;
  static bool isLoggedIn = false;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      id = prefs.getString('id');
      empID = prefs.getString('emp_id');
      name = prefs.getString('name');
        token = prefs.getString('push_token');
      // userId = prefs.getString('userId');
    }
  }

  static Future<void> setUserInfo(String fname, String eID, String ID,String pToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('name', fname);
    await prefs.setString('id', ID);
    await prefs.setString('emp_id', eID);
     await prefs.setString('push_token', pToken);


    name = fname;
    id = ID;
    empID = eID;
    token=pToken;
    // AppUtility.userId = userId;
    isLoggedIn = true;
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    id = null;
    empID = null;
    name = null;
    // userId = null;
    isLoggedIn = false;
  }
}
