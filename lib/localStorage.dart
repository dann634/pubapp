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




