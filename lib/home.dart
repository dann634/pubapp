import 'dart:io';

import 'package:flutter/material.dart';
import 'utils.dart';
import 'connection.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? dayCount;

  bool isGoingOut = false;
  bool hasLoaded = false;

  @override
  void initState() {
    super.initState();
    updateAvailabilityStatus();
  }

  void updateAvailabilityStatus() async {
    final data = await getProfile();
    if(data == null) {
      return;
    }
    isGoingOut = data["isAvailable"] != 0;
    hasLoaded = true;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 30
        ),
        alignment: Alignment.center,
        color: DEFAULT_BLACK,
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("You've been out",
              style: TextStyle(
                fontSize: 20
              ),
            ),

            Text(dayCount ?? "0",
              style: TextStyle(
                  fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text("times this month",
              style: TextStyle(
                  fontSize: 20
              ),
            ),

            Spacer(),

            Text("Pub?",
              style: TextStyle(
                fontSize: 22
              ),
            ),

            hasLoaded ? TextButton(
              onPressed: () {
                isGoingOut = !isGoingOut;
                setAvailability(isGoingOut);
                setState(() {

                });
              },
              style: TextButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 80),
                backgroundColor: isGoingOut ? Colors.green : Colors.red,
                foregroundColor : DEFAULT_BLACK,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                )
              ),
              child: Text(isGoingOut ? "Yeah" : "Nah"),
            ) : CircularProgressIndicator(color : DEFAULT_WHITE)



          ],
        ),
      ),
    );
  }


}


