import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON responses
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final HOST = "http://ec2-18-134-134-33.eu-west-2.compute.amazonaws.com:5000";

final secureStorage = FlutterSecureStorage();


String? username;
String? fullName;
bool? isAvailable;

final Map<String, String> headers = {
  'Content-Type': 'application/json',
  "Authorization": "",
};

// Fetch data from the API
Future<bool> refreshAccessToken() async {

  String? refresh_token = await secureStorage.read(key: 'refreshToken');

  if (refresh_token == null) {
    return false;
  }

  String data;
  final url = Uri.parse("$HOST/refresh");
  try {
    final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json',
        "Authorization": "Bearer $refresh_token"},
    );
    if (response.statusCode == 200) {
      // Decode the JSON response
      final jsonData = json.decode(response.body);
      String newAccessToken = jsonData["access_token"];
      headers["Authorization"] = "Bearer $newAccessToken";
      return true;
    } else {
      data = "Failed to load data. Status code: ${response.statusCode}";
    }
  } catch (error) {
    data = "Error: $error";
  }
  return false;
}

// Fetch data from the API
Future<String> register(String localUsername, String password, String localFullName) async {
  String res = "";
  final url = Uri.parse("$HOST/register");
  final data = {
    "username": localUsername,
    "password": password,
    "fullName" : localFullName,
  };

  try {
    final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data)
    );

    if(response.statusCode == 401) {
      //Username taken
      return "Error: Username Taken";
    }

    if (response.statusCode == 201) {
      // Decode the JSON response
      final jsonData = json.decode(response.body);
      headers["Authorization"] = "Bearer ${jsonData["access_token"]}";

      //Store refresh token in secure storage
      String refreshToken = jsonData['refresh_token'];
      await secureStorage.write(key: 'refreshToken', value: refreshToken);

      username = localUsername;
      fullName = localFullName;
      isAvailable = false;

    } else {
      res = "Failed to load data. Status code: ${response.statusCode}";
    }
  } catch (error) {
    res = "Error: $error";
  }
  return res;
}

Future<bool> login(String username, String password) async {
  String res = "";
  final url = Uri.parse("$HOST/login");
  final data = {
    "username": username,
    "password": password,
  };

  try {
    final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data)
    );

    if(response.statusCode == 401) {
      //Username taken
      res = "Error: Invalid Username or Password";
      return false;
    }

    if (response.statusCode == 200) {
      // Decode the JSON response
      final jsonData = json.decode(response.body);
      headers["Authorization"] = "Bearer ${jsonData["access_token"]}";

      //Store refresh token in secure storage
      String refreshToken = jsonData['refresh_token'];
      await secureStorage.write(key: 'refreshToken', value: refreshToken);

    } else {
      res = "Failed to load data. Status code: ${response.statusCode}";
      return false;
    }
  } catch (error) {
    res = "Error: $error";
    return false;
  }
  return true;
}

Future<Map<String, dynamic>?> getProfile() async {

  final url = "$HOST/me";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode != 200) {
    return null;
  }

  // Parse the JSON response into a Map and return it
  final data = jsonDecode(response.body);

  username = data["username"];
  fullName = data["fullname"];
  isAvailable = data["isAvailable"] != 0;

  return data;
}

Future<List?> getFriends() async {


  final response = await handleGETRequest("$HOST/me/friends", headers);

  if(response.statusCode != 200) {
    return null;
  }

  // Parse the JSON response into a Map and return it
  final data = jsonDecode(response.body);

  return data;
}

Future<List?> getFriendRequests() async {

  final url = "$HOST/me/friends/requests";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode != 200) {
    return null;
  }

  // Parse the JSON response into a Map and return it
  final data = jsonDecode(response.body);

  return data;
}


Future<bool> respondToFriendRequest(String friendUsername, bool accept) async {
  final url = "$HOST/me/friends/requests/respond";

  final data = {
    "friend_username" : friendUsername,
    "choice" : accept ? "add" : "remove",
  };

  final response = await handlePOSTRequest(url, data);

  return response.statusCode == 201;

}


Future<bool> sendFriendRequest(String username) async {

  final url = "$HOST/me/friends/add";

  final data = {
    "friend_username" : username,
  };

  final response = await handlePOSTRequest(url, data);

  if(response.statusCode == 201) {
    return true;
  }

  return false;
}

Future<void> setAvailability(value) async {
  final url = "$HOST/me/availability";

  final data = {
    "is_available" : value
  };

  await handlePOSTRequest(url, data);
}

Future<void> addDrinksToProfile(List<double> units, List<String> drinkTypes) async {
  final url = "$HOST/me/drinks/add";

  final data = {
    "units": units,
    "types": drinkTypes,
  };

  await handlePOSTRequest(url, data);
}


Future<double> getUnits(String time_frame) async {
  final url = "$HOST/me/drinks/units?time_frame=$time_frame";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode != 200) {
    return -1;
  }

  final units = jsonDecode(response.body);

  return double.parse(units);
}



Future<http.Response> handleGETRequest(uri, localHeaders) async {

  final url = Uri.parse(uri);

  http.Response response;

  response = await http.get(
      url,
      headers: localHeaders,
  );

  if(response.statusCode == 401 || response.statusCode == 422) {
    //Invalid access code or expired
    await refreshAccessToken();

    response = await http.get(
      url,
      headers: localHeaders,
    );

  }
  return response;
}



Future<http.Response> handlePOSTRequest(uri, data) async {


  final url = Uri.parse(uri);
  http.Response response;

  response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(data),
  );

  if(response.statusCode == 401 || response.statusCode == 422) {
    await refreshAccessToken();
    response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }
  return response;
}
