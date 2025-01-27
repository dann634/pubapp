import 'package:flutter/material.dart';
import 'package:pubapp/connection.dart';
import 'package:pubapp/utils.dart';

List<Friend> friends = List<Friend>.empty(growable: true);

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {

  bool hasLoaded = false;
  Container? friendsContainer;
  List<Widget> friendEntries = List<Widget>.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Friends"),
        centerTitle: true,
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 20),
            icon: Icon(Icons.person_add), // Icon for the button
            onPressed: () {
              // Action when the button is pressed
            Navigator.push(context,  MaterialPageRoute(builder: (context) => AddFriendScreen()));
            },
          ),
        ],
      ),


      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 150,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10
          ),
          child: hasLoaded ? friendsContainer : CircularProgressIndicator(
            color: DEFAULT_WHITE,
          ),
        ),
      ),

    );
  }

  @override
  void initState() {
    super.initState();
    //Load all friends

    getFriends().then((value) {

      if(value == null) {
        return;
      }

      if(value.isEmpty) {
        friendsContainer = Container(
          child: Text("Add Some Friends!"),
        );
        hasLoaded = true;
        return;
      }

      for(int i = 0; i < value.length; i++) {

        final friend_data = value[i];
        if(friend_data == null) {
          break;
        }

        Friend friend = Friend(friend_data[0], friend_data[1], friend_data[2]);
        friends.add(friend);

        Container row = getFriendEntry(friend);
        friendEntries.add(row);

      }


      friendsContainer = Container(
        child: Column(
          children: friendEntries,
        ),
      );
      hasLoaded = true;

    });

  }

  Container getFriendEntry(Friend friend) {
    return Container(
      child : Row(

        children: [
          Text(friend.username),
          Text(friend.isAvailable ? "Available" : "Not Available"),
        ],

      ),
    );
  }

}


class Friend {

  String username;
  String fullname;
  bool isAvailable;

  Friend(this.username, this.fullname, this.isAvailable);
}

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {

  String _errorMsg = "";
  bool _hideError = true;

  List<Friend> friendRequests = List<Friend>.empty(growable: true);

  void _showErrorMessage() {
    setState(() {
      _hideError = false;
    });
  }


  @override
  void initState() {
    super.initState();
    //Get all friend requests

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Add Friend"),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Container(


          padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15
          ),

          child: Column(
            children: [
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                          color: DEFAULT_WHITE,
                      ),
                      cursorColor: DEFAULT_BLACK,
                      decoration: InputDecoration(

                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15
                          ),

                          hintText: "Search",
                          labelText: "Search...",
                          labelStyle: TextStyle(
                              color : DEFAULT_WHITE,
                          ),
                          focusColor: Colors.white,

                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: DEFAULT_WHITE)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: DEFAULT_WHITE)
                          )
                      ),

                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,  // Background color to white
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),  // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), // Padding for better button size
                      foregroundColor: DEFAULT_BLACK,
                    ),
                    child: Text("Add",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                      ),
                    ),
                  )

                ],
              ),
              Offstage(
                offstage: _hideError,
                child: Text("Error: $_errorMsg",
                  style: TextStyle(
                    color: DEFAULT_RED,
                  ),
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
