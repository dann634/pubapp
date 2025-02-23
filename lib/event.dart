import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'connection.dart';
import 'utils.dart';

var hasAgreed = false;

class EventScreen extends StatefulWidget {
const EventScreen({super.key});

@override
State<EventScreen> createState() => _EventScreen();
}

class _EventScreen extends State<EventScreen> {

bool hasLoaded = false;
Container? eventsContainer;
List<Widget> friendEntries = List<Widget>.empty(growable: true);

@override
Widget build(BuildContext context) {
return Scaffold(


  appBar: AppBar(
    title: Text("Events"),
    centerTitle: true,
    actions: [
      IconButton(
        padding: EdgeInsets.only(right: 20),
        icon: Icon(Icons.person_add), // Icon for the button
        onPressed: () {
          // Action when the button is pressed
          //Navigator.push(context,  MaterialPageRoute(builder: (context) => AddFriendScreen()));
        },
      ),
    ],
  ),


  body: RefreshIndicator(
    onRefresh: checkProfile,
      child: Container(
        alignment: Alignment.center,
        child: hasLoaded ? eventsContainer : CircularProgressIndicator(
          color: DEFAULT_WHITE,
        ),
      ),

  ),

);
}

@override
void initState() {
  super.initState();
  checkProfile();
}

Future<void> checkProfile() async {
  final BACProfile = await getBACProfile();
  if(BACProfile.length == 0 ){

  }else{
    if(BACProfile["isEnabled"] == true){
      //Return Container with the event page
    }else{
      //return container with the sign up page
    }
  }

  debugPrint("Profile Data: $profile");

  setState(() {
    hasLoaded = true;
  });
  if (profile[0] != 1) {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventSettingsScreen()),
    );
    setState(() {}); // Update the UI if needed
  }
}
}

class EventSettingsScreen extends StatefulWidget {
  const EventSettingsScreen({super.key});

  @override
  State<EventSettingsScreen> createState() => _EventSettingsScreenState();
}

class _EventSettingsScreenState extends State<EventSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "Event Screen"),
      body: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20
        ),
        child: Column(

          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white10,
                  border: Border.all(color: Colors.black)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Enable Event Screen",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  CupertinoSwitch(
                    value: hasAgreed,
                    onChanged: (value) {
                      setState(() {
                        hasAgreed = !hasAgreed;
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

