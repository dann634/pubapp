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

  String? unitCount;
  double? unitCountNumber;

  bool isGoingOut = false;
  bool hasLoaded = false;

  @override
  void initState() {
    super.initState();
    updateAvailabilityStatus();
    updateUnits();
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

  void updateUnits() async {
    getUnits("month").then((value){
      unitCountNumber = value;
      unitCount = value.toString();
      setState(() {});
    });
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

            SizedBox(
              height: 70,
            ),

            Text("You've had",
              style: TextStyle(
                fontSize: 20
              ),
            ),

            Text(unitCount ?? "0",
              style: TextStyle(
                  fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text("units in the last month",
              style: TextStyle(
                  fontSize: 20
              ),
            ),

            SizedBox(height: 10,),

            Text("That's an average of " + ((unitCountNumber ?? 0) / 31).toStringAsPrecision(2) + " units per day!",
              style: TextStyle(
                color: DEFAULT_GREY
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


