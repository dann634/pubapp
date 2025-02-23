import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON responses
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'localStorage.dart';
import 'package:intl/intl.dart';


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

Future<void> logout() async {
  final url = "$HOST/logout";

  String? refresh_token = await secureStorage.read(key: "refreshToken");

  final data = {
    "refresh_token" : refresh_token
  };

  await handlePOSTRequest(url, data);
}

Future<List<dynamic>?> getProfile() async {

  final url = "$HOST/me";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode != 200) {
    return null;
  }

  // Parse the JSON response into a Map and return it
  final data = jsonDecode(response.body);

  username = data[0];
  fullName = data[1];
  isAvailable = data[2] != 0;

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


Future<List<dynamic>> sendFriendRequest(String username) async {

  final url = "$HOST/me/friends/add";

  final data = {
    "friend_username" : username,
  };

  final response = await handlePOSTRequest(url, data);
  final message = jsonDecode(response.body);

  return [response.statusCode == 201, message["message"]];
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
    return 0.0;
  }

  final mapData = jsonDecode(response.body);

  final value = mapData["units"];
  if(value is String) {
    return double.parse(value);
  }


  return mapData["units"];
}

Future<Map<String, dynamic>> getDrinkList() async {
  final url = "$HOST/me/drinks";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode != 200) {
    return {};
  }

  final map = jsonDecode(response.body);

  return map;
}

Future<int> getFriendCount() async {
  final url = "$HOST/me/friends/count";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode != 200) {
    return 0;
  }

  final value = jsonDecode(response.body);

  return value;
}

Future<List<dynamic>> getLeaderboard() async {
  final url = "$HOST/me/friends/rankings";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode != 200) {
    return [];
  }

  final units = jsonDecode(response.body);
  return units;
}

Future<dynamic> getLeaderboardRank() async {
  final url = "$HOST/me/ranking";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode != 200) {
    return -1;
  }

  final value = jsonDecode(response.body);
  return value;
}

Future<void> updateBACProfile(isAccepted, weight, gender) async {
  final url = "$HOST/me/bac/add";

  final data = {
    "isAccepted": isAccepted,
    "weight" : weight,
    "gender" : gender
  };

  final response = await handlePOSTRequest(url, data);

  if(response.statusCode == 201) {
    //Added successfully
  }
}

Future<List<dynamic>> getBACProfile() async {
  final url = "$HOST/me/bac/profile";

  final response = await handleGETRequest(url, headers);

  List<dynamic>? list;

  if(response.statusCode == 200) {
    list = jsonDecode(response.body);

    //Save to local memory

    await saveBACProfile(list![0] == 1, list[1], list[2]);

    return [list[0] == 1, list[1], list[2]];

  } else if (response.statusCode == 404) {
    await saveBACProfile(false, -1.0, "null");
    return [];
  }

  return [];
}

Future<void> createEvent() async {
  final url = "$HOST/me/event/create";

  final response = await handlePOSTRequest(url, {});

  if(response.statusCode == 201) {
    //Created successfully - store event code in storage
    final data = jsonDecode(response.body);
    final eventID = data["eventId"];
    if(eventID != null) {
      await saveEventId(int.parse(eventID));
      return eventID;
    }
  }
}

Future<bool> joinEvent(eventId) async {
  final url = "$HOST/me/event/join";

  final data = {
    "event_id" : eventId
  };

  final response = await handlePOSTRequest(url, data);

  if(response.statusCode == 404) {
    //event does not exist
    return false;
  }

  if(response.statusCode == 200) {
    //Created successfully - store event code in storage
    final data = jsonDecode(response.body);
    final eventID = data["eventId"];
    if(eventID != null) {
      await saveEventId(int.parse(eventID));
      return true;
    }
  }
  return false;
}

Future<bool> leaveEvent() async {
  final url = "$HOST/me/event/leave";

  final response = await handlePOSTRequest(url, {});

  return response.statusCode == 200;
}

Future<List<dynamic>> getEventDrinkList() async {

  //get last request
  String? lastRequest = await getEventLastAccess();
  lastRequest ??= "01-01-2020-12-00-00";

  final url = "$HOST/me/event/drinks/get?last_request=$lastRequest";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final drinkList = data[0];

    //Set new access time
    final newTime = data[1];
    DateTime dateTime = DateTime.parse(newTime);
    String formattedDate = DateFormat("dd-MM-yyyy-HH-mm-ss").format(dateTime);
    await saveEventLastAccess(formattedDate);

    return drinkList;
  }

  return [];
}

Future<bool> isUserInEvent() async {
  final url = "$HOST/me/event";

  final response = await handleGETRequest(url, headers);

  return response.statusCode == 200;
}

Future<List<dynamic>> getEventBACList() async {
  final url = "$HOST/me/event/bac/get";

  final response = await handleGETRequest(url, headers);

  if(response.statusCode == 200) {
    final list = jsonDecode(response.body);
    return list;
  }

  return [];
}

Future<void> deleteBACProfile() async {
  final url = "$HOST/me/bac/delete";

  await handlePOSTRequest(url, headers);
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
    ).timeout(Duration(seconds: 5));

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
    ).timeout(Duration(seconds: 5));
  }
  return response;
}
