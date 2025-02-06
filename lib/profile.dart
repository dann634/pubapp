import 'dart:math';

import 'package:flutter/material.dart';
import 'connection.dart';
import 'drinks.dart';
import 'localStorage.dart';
import 'utils.dart';
import 'login.dart';
import 'main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  List<int> drinkNumberList = List<int>.empty(growable: true);

  int drinkTotal = 0;
  int friendTotal = 0;

  bool hasLoaded = false;


  @override
  void initState() {
    super.initState();
    loadProfileStats();
  }

  void loadProfileStats() async {

    //Load saved data first

    int? drinks = await getTotalDrinks();
    if(drinks != null) {
      drinkTotal = drinks;
    }

    int? localFriendCount = await getLocalFriendCount();
    if(localFriendCount != null) {
      friendTotal = localFriendCount;
    }

    setState(() {});


    //Now update from api


    final map = await getDrinkList();
    final friend_count = await getFriendCount();

    List<String> drinkTypeList = List<String>.empty(growable: true);

    for(int i = 0; i < allDrinks.length; i++) {
      String drinkCategory = allDrinks[i].type;
      if(!drinkTypeList.contains(drinkCategory)) {
        drinkTypeList.add(drinkCategory);
        drinkNumberList.add(0);
      }
    }

    drinkNumberList[0] = map["Beer"] ?? 0; //Change for all
    drinkNumberList[1] = map.containsKey("Cider") ? map["Cider"] : 0;
    drinkNumberList[2] = map.containsKey("Vodka") ? map["Vodka"] : 0;
    drinkNumberList[3] = map.containsKey("Tequila") ? map["Tequila"] : 0;
    drinkNumberList[4] = map.containsKey("Rum") ? map["Rum"] : 0;
    drinkNumberList[5] = map.containsKey("Gin") ? map["Gin"] : 0;
    drinkNumberList[6] = map.containsKey("Whisky") ? map["Whisky"] : 0;
    drinkNumberList[7] = map.containsKey("Brandy") ? map["Brandy"] : 0;
    drinkNumberList[8] = map.containsKey("Other") ? map["Other"] : 0;

    //Update Total Drinks
    drinkTotal = 0;
    map.forEach((key, value) {
      drinkTotal += value as int;
    });

    //Update Friends Number
    friendTotal = friend_count;

    hasLoaded = true;

    setState(() {});

    saveTotalDrinks(drinkTotal);
    saveFriendCount(friendTotal);

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        title: Text(username ?? "",
          style: TextStyle(
            color: DEFAULT_WHITE,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //Go to settings
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
            icon: Icon(Icons.settings_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 20
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 100.0, // width of the circle
                height: 100.0, // height of the circle
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // makes the container circular
                  color: Colors.blue, // background color of the circle
                ),
                child: Center(
                  child: Icon(
                    Icons.person, // The icon you want inside the circle
                    color: Colors.white, // color of the icon
                    size: 40.0, // size of the icon
                  ),
                ),
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(

                      children: [
                        getProfileNumber(drinkTotal.toString()),
                        Text("Drinks")
                      ],

                    ),

                    Column(

                      children: [
                        getProfileNumber((friendTotal ?? 0).toString()),
                        Text("Friends")
                      ],

                    ),

                    Column(
                      children: [
                        getProfileNumber("#-"),
                        Text("Rank")
                      ],

                    ),
                  ],
                ),
              ),

              Column(
                spacing: 8,
                children: [
                  getDrinkRecord("Beer", hasLoaded ? drinkNumberList[0] : 0),
                  getDrinkRecord("Cider", hasLoaded ? drinkNumberList[1] : 0),
                  getDrinkRecord("Vodka", hasLoaded ? drinkNumberList[2] : 0),
                  getDrinkRecord("Tequila", hasLoaded ? drinkNumberList[3] : 0),
                  getDrinkRecord("Rum", hasLoaded ? drinkNumberList[4] : 0),
                  getDrinkRecord("Gin", hasLoaded ? drinkNumberList[5] : 0),
                  getDrinkRecord("Whiskey", hasLoaded ? drinkNumberList[6] : 0),
                  getDrinkRecord("Brandy", hasLoaded ? drinkNumberList[7] : 0),
                  getDrinkRecord("Other", hasLoaded ? drinkNumberList[8] : 0),
                ],
              )


            ],
          ),
        ),
      )
    );
  }

  Text getProfileNumber(String text) {
    return Text(text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 19,
      ),
    );
  }

  Container getDrinkRecord(String drinkName, int amount) {
    return Container(

      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 15
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color.fromRGBO(40, 40, 40, 1), // Border color
            width: 2.0,          // Border width
          ),
      ),


      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$drinkName:",
            style: TextStyle(
              fontSize: 16,
            ),
          ),

          Text(amount.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }


}



class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55,
        foregroundColor: DEFAULT_WHITE,
        backgroundColor: DEFAULT_BLACK,
        title: Text("Settings"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: Icon(Icons.arrow_back_ios),
        ),

      ),

      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 30,
        ),
        child: Column(
          spacing: 25,
          children: [

            getSettingsButton("Logout", logoutBtnAction),
            getSettingsButton("Delete Account", deleteAccount)

          ],
        ),
      ),
    );

  }

  void logoutBtnAction() {

    //Logout Request
    logout();

    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));


  }

  void deleteAccount() {

  }


  TextButton getSettingsButton(String text, Function action) {
    return TextButton(
      onPressed: () {
        action();
      },
      style: TextButton.styleFrom(
        fixedSize: Size(MediaQuery.of(context).size.width, 50),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        )
      ),
      child: Text(text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16
      ),
      ),
    );
  }
}



