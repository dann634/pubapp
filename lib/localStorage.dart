import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> saveAvailability(bool isAvailable) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("isAvailable", isAvailable);
}

Future<bool?> getAvailability() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? value = prefs.getBool('isAvailable'); // Returns null if not set
  return value;
}

Future<void> saveMonthlyUnits(double units) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble("units_monthly", units);
}

Future<double?> getMonthlyUnits() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('units_monthly'); // Returns null if not set
}

Future<void> saveTotalDrinks(int drinks) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("total_drinks", drinks);
}

Future<int?> getTotalDrinks() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('total_drinks'); // Returns null if not set
}

Future<void> saveFriendCount(int friend_count) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("friend_count", friend_count);
}

Future<int?> getLocalFriendCount() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('friend_count'); // Returns null if not set
}

Future<void> saveEventId(int eventId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("eventId", eventId);
}

Future<int?> getEventId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('eventId'); // Returns null if not set
}

Future<void> saveEventLastAccess(String time) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("last_request", time);
}

Future<String?> getEventLastAccess() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('last_request'); // Returns null if not set
}


Future<void> saveBACProfile(bool isEnabled, double weight, String gender) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList("bac_profile", [isEnabled.toString(), weight.toString(), gender]);
}

Future<Map<String, dynamic>> getBACProfileLocal() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList("bac_profile");
  if(data != null) {
    try {
      return {
        "isEnabled": bool.parse(data[0]),
        "weight" : double.parse(data[1]),
        "gender" : data[2]
      };
    } catch(e) {
      return {};
    }
  }
  return {};
}








