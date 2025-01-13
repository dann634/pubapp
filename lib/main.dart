import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Bar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  int _currentIndex = 2; // Start at the "Home" screen (index 2)
  final List<Widget> _screens = [
    MapScreen(),
    FriendsScreen(),
    HomeScreen(),
    EventsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Color _barColor = Color.fromRGBO(24, 24, 24, 1);
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // Disable the ripple effect
          highlightColor: Colors.transparent, // Remove highlight on tap
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.shifting,
          // Keep the shifting effect
          // Apply background color
          selectedItemColor: Colors.white,
          // Style selected item
          unselectedItemColor: Colors.grey,
          // Style unselected items
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
              backgroundColor: _barColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Friends',
              backgroundColor: _barColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: _barColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events',
              backgroundColor: _barColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: _barColor,
            ),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  // Set an initial location (center of the map)
  final LatLng _center = const LatLng(-33.86, 151.20);

  // Map creation callback
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps Sample App'),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ),
    );
  }
}

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(24, 24, 24, 1),
        toolbarHeight: 20,
        ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(255, 153, 0, 1),
          child: Icon(
            Icons.add,
            size: 35,
            color: Colors.black,
          ),
          onPressed: () {
            //ADD SHOW SEARCH MENU HERE
        }
      ),

      backgroundColor: Color.fromRGBO(49, 49, 49, 1),
      body: Center(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text("Available",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),

            Text("Unavailable",
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isYeah = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(49, 49, 49, 1),
      body: Center(
        child: Column(
          
          spacing: 40,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big text at the top
            Text(
              "Pub?",
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white60
              ),
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  _isYeah = !_isYeah;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 250, // Make the button circular
                height: 250,
                decoration: BoxDecoration(
                  color: _isYeah ? Colors.green : Colors.red,
                  shape: BoxShape.circle, // Circular shape
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _isYeah ? 'Yeah' : 'Nah',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fill out EventsScreen functionality here
    return Center(
      child: Text('Events Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fill out ProfileScreen functionality here
    return Center(
      child: Text('Profile Screen', style: TextStyle(fontSize: 24)),
    );
  }
}
