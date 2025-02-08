import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pubapp/utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'login.dart';
import 'home.dart';
import 'friends.dart';
import 'map.dart';
import 'profile.dart';
import 'drinks.dart';
import 'connection.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pub?',
      theme: ThemeData(
        primarySwatch: Colors.blue,

        textTheme: TextTheme(
          bodyLarge: TextStyle(color: DEFAULT_WHITE), // Set default text color for large body text
          bodyMedium: TextStyle(color: DEFAULT_WHITE), // Set default text color for medium body text
          bodySmall: TextStyle(color: DEFAULT_WHITE), // Set default text color for small body text
          headlineMedium: TextStyle(color: DEFAULT_WHITE), // For medium headings
          headlineSmall: TextStyle(color: DEFAULT_WHITE), // For small headings
          headlineLarge: TextStyle(color: DEFAULT_WHITE), // For medium headings
          titleMedium: TextStyle(color: DEFAULT_WHITE), // For medium headings
          titleSmall: TextStyle(color: DEFAULT_WHITE), // For medium headings
          titleLarge: TextStyle(color: DEFAULT_WHITE), // For medium headings
          labelMedium: TextStyle(color: DEFAULT_WHITE), // For medium headings
          displayMedium: TextStyle(color: DEFAULT_WHITE), // For medium headings
          displayLarge: TextStyle(color: DEFAULT_WHITE), // For medium headings
          displaySmall: TextStyle(color: DEFAULT_WHITE), // For medium headings
          labelLarge: TextStyle(color: DEFAULT_WHITE), // For medium headings
          labelSmall: TextStyle(color: DEFAULT_WHITE), // For medium headings
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: DEFAULT_BLACK,
          foregroundColor: DEFAULT_WHITE,
        ),
        scaffoldBackgroundColor: DEFAULT_BLACK,

      ),





      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int currentIndex = 2;

  bool? isLoginNeeded; // Use nullable bool to handle loading state.


  final List<Widget> _pages = [
    MapScreen(),
    FriendsScreen(),
    HomePage(),
    DrinksScreen(),
    ProfileScreen()
  ];

  void _onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus().then((value) async {
      // Show appropriate page once login status is determined.
      if(isLoginNeeded!) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        final profile_data = await getProfile();

        if(profile_data == null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      }
    });

  }

  Future<void> _checkLoginStatus() async {

    bool doesRefreshTokenExist = await _doesRefreshTokenExist();
    isLoginNeeded = !doesRefreshTokenExist;

    //Try get access token
    if(doesRefreshTokenExist) {
      bool isRefreshTokenValid = await refreshAccessToken();
      print("$isRefreshTokenValid refresh token");
      isLoginNeeded = !isRefreshTokenValid;
    }

    setState(() {
       // Update state when async task is complete.
    });
  }

  Future<bool> _doesRefreshTokenExist() async {
    String? refreshToken = await secureStorage.read(key: 'refreshToken');
    return refreshToken != null;
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while determining login status.
    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color.fromRGBO(18, 18, 18, 1),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color.fromRGBO(100, 100, 100, 1),
          iconSize: 25,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Event',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_outlined),
              label: 'Drinks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );



  }




}


