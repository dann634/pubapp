import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON responses
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final HOST = "http://ec2-18-134-134-33.eu-west-2.compute.amazonaws.com:5000";

final secureStorage = FlutterSecureStorage();

String? _accessToken;

String? username;
String? fullName;
bool? isAvailable;

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
      _accessToken = jsonData['access_token']; // Update the access token
    } else {
      data = "Failed to load data. Status code: ${response.statusCode}";
      return false;
    }
  } catch (error) {
    data = "Error: $error";
    return false;
  }
  return true;
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
      _accessToken = jsonData['access_token'];

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
      _accessToken = jsonData['access_token'];

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

Future<List?> getProfile() async {

  final url = Uri.parse("$HOST/me");

  http.Response response;

  response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $_accessToken",
    },
  );

  if (response.statusCode != 200) {
    refreshAccessToken();
    response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $_accessToken",
      },
    );
  }

  if(response.statusCode != 200) {
    return null;
  }

  // Parse the JSON response into a Map and return it
  final data = jsonDecode(response.body);

  username = data[0];
  fullName = data[1];
  isAvailable = data[2] as bool;

  return data;
}

Future<List?> getFriends() async {

  final url = Uri.parse("$HOST/me/friends");

  http.Response response;

  response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $_accessToken",
    },
  );

  if (response.statusCode != 200) {
    refreshAccessToken();
    response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $_accessToken",
      },
    );
  }

  if(response.statusCode != 200) {
    return null;
  }

  // Parse the JSON response into a Map and return it
  final data = jsonDecode(response.body);

  return data;
}


