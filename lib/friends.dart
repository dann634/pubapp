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


      body: RefreshIndicator(
        onRefresh: loadFriendsList,
        child: SingleChildScrollView(
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
      ),

    );
  }

  @override
  void initState() {
    super.initState();
    //Load all friends
    loadFriendsList();
  }

  Future<void> loadFriendsList() async {
    final friendsList = await getFriends();
    friends.clear();
    friendEntries.clear();

    if(friendsList == null) {
      return;
    }

    if(friendsList.isEmpty) {
      friendsContainer = Container(
        child: Text("Add Some Friends!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      hasLoaded = true;
      setState(() {});
      return;
    }

    friendEntries.add(Divider(color: Colors.grey));

    for(int i = 0; i < friendsList.length; i++) {

      final friend_data = friendsList[i];
      if(friend_data == null) {
        break;
      }

      Friend friend = Friend(friend_data["username"], friend_data["fullname"], friend_data["isAvailable"] != 0);
      friends.add(friend);

      Container row = getFriendEntry(friend);
      friendEntries.add(row);
      friendEntries.add(Divider(color: Colors.grey));

    }


    friendsContainer = Container(
      padding: EdgeInsets.symmetric(
          horizontal: 10
      ),
      child: Column(
        children: friendEntries,
      ),
    );
    hasLoaded = true;
    setState(() {});
  }

  Container getFriendEntry(Friend friend) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(friend.username,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(friend.fullname,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          Row(
            spacing: 10,
            children: [

            CircleAvatar(
            radius: 10, // Half the diameter
            backgroundColor: friend.isAvailable ? Colors.green : Colors.red, // Set the color of the circle
            )


      ],
          )

        ],
      )
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
  final inputField = TextEditingController();
  Column? friendRequestsColumn;
  bool hasLoaded = false;

  void _showErrorMessage() {
    setState(() {
      _hideError = false;
    });
  }


  @override
  void initState() {
    super.initState();
    //Get all friend requests
    loadFriendRequestList();

  }

  void loadFriendRequestList() {
    getFriendRequests().then((list) {

      if(list!.isEmpty) {
        friendRequestsColumn = Column(
          children: [],
        );
        hasLoaded = true;
        setState(() {});
        return;
      }

      //Show requests
      List<Widget> widgets = List<Widget>.empty(growable: true);

      widgets.add(Divider(color: DEFAULT_GREY));

      for(int i = 0; i < list.length; i++) {
        final user = list[i];
        widgets.add(getFriendRequestRow(user[0], user[1]));
        widgets.add(Divider(color: DEFAULT_GREY,));
      }

      friendRequestsColumn = Column(
        children: widgets,
      );

      hasLoaded = true;
      setState(() {});

    });
  }

  Row getFriendRequestRow(String username, String fullName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(username,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(fullName,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),

        Row(
          spacing: 10,
          children: [
            TextButton(
              onPressed: () {
                respondToFriendRequest(username, true).then((onValue) {
                  //Remove row from screen
                  loadFriendRequestList();
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,  // Background color to white
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),  // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 20), // Padding for better button size
                foregroundColor: DEFAULT_BLACK,
              ),
              child: Text("Accept",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                respondToFriendRequest(username, false).then((onValue) {
                  //Remove row from
                  loadFriendRequestList();
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,  // Background color to white
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),  // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 20), // Padding for better button size
                foregroundColor: DEFAULT_BLACK,
              ),
              child: Text("Ignore",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
            )


          ],
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Add Friend"),
        centerTitle: true,

        actions: [
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 20),
            onPressed: () {
              loadFriendRequestList();
            },
            icon: Icon(Icons.refresh),
          )
        ],

      ),
      body: SingleChildScrollView(
        child: Container(


          padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15
          ),

          child: Column(
            spacing: 10,
            children: [
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputField,
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
                    onPressed: () async {
                      bool addedSuccessfully = await sendFriendRequest(inputField.text);
                      if(!addedSuccessfully) {
                        _errorMsg = "User not found";
                        _showErrorMessage();
                      }
                    },
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

              hasLoaded ? friendRequestsColumn! : Container(),

            ],
          ),

        ),
      ),
    );
  }
}
