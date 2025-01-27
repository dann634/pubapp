import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pubapp/connection.dart';
import 'package:pubapp/utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'login.dart';
import 'home.dart';
import 'friends.dart';
import 'map.dart';
import 'profile.dart';
import 'events.dart';

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

  bool? isLoginNeeded; // Use nullable bool to handle loading state.

  int _currentIndex = 2;

  final List<Widget> _pages = [
    MapScreen(),
    FriendsScreen(),
    HomePage(),
    EventsScreen(),
    ProfileScreen()
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
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
        //Get profile
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

    // //Try get access token
    if(doesRefreshTokenExist) {
      bool isRefreshTokenValid = await refreshAccessToken();
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
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color.fromRGBO(18, 18, 18, 1),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color.fromRGBO(100, 100, 100, 1),
          iconSize: 25,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/icons/friends.svg",
                width: 20,
                height: 25,
                color: _currentIndex == 1
                    ? Colors.white // Selected color
                    : Color.fromRGBO(100, 100, 100, 1), // Unselected color
              ),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );



  }

}

