import 'package:flutter/material.dart';
import 'package:pubapp/utils.dart';
import 'connection.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
            padding: EdgeInsets.only(right: 15),
            onPressed: () {

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
                        getProfileNumber("0"),
                        Text("Drinks")
                      ],

                    ),

                    Column(

                      children: [
                        getProfileNumber("0"),
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
                  getDrinkRecord("Beer", 0),
                  getDrinkRecord("Cider", 0),
                  getDrinkRecord("Wine", 0),
                  getDrinkRecord("Vodka", 0),
                  getDrinkRecord("Tequila", 0),
                  getDrinkRecord("Rum", 0),
                  getDrinkRecord("Gin", 0),
                  getDrinkRecord("Whiskey", 0),
                  getDrinkRecord("Brandy", 0),
                  getDrinkRecord("Other Spirits", 0),
                  getDrinkRecord("Other Non-Spirits", 0),
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


