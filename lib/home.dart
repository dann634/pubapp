import 'dart:io';

import 'package:flutter/material.dart';
import 'utils.dart';
import 'connection.dart';
import 'localStorage.dart';

bool isFirstLoad = true;

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

    bool? value = await getAvailability();

    if(value != null) {
      isGoingOut = value;
      hasLoaded = true;
      setState(() {});
      return;
      //Saves calling the api
    }

    final data = await getProfile();
    if(data == null) {
      return;
    }
    isGoingOut = data[2] != 0;
    hasLoaded = true;
    saveAvailability(isGoingOut);
    setState(() {});
  }

  void updateUnits() async {

    double? local_units = await getMonthlyUnits(); //Last value stored on disk
    if(local_units != null) {
      unitCountNumber = local_units;
      unitCount = local_units.toStringAsPrecision(4);
      setState(() {});
    }

    //On first load get number from server
    if(!isFirstLoad) {
      return;
    }

    double units = await getUnits("month"); //API request for most recent number

    unitCountNumber = units;
    if (unitCountNumber == 0) {
      unitCount = "0.0"; // Explicitly handle zero case
    } else {
      unitCount = unitCountNumber?.toStringAsFixed(2); // Format to 2 decimal places
    }
    saveMonthlyUnits(unitCountNumber ?? 0);
    setState(() {});
    isFirstLoad = false;
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
                saveAvailability(isGoingOut);
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


