import 'package:flutter/material.dart';
import 'utils.dart';

class DrinksScreen extends StatefulWidget {
  const DrinksScreen({super.key});

  @override
  State<DrinksScreen> createState() => _DrinksScreenState();
}

class _DrinksScreenState extends State<DrinksScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drinks"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 30,
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                dividerColor: Color.fromRGBO(44, 44, 44, 1),
                indicatorColor: DEFAULT_ORANGE,
                labelColor: DEFAULT_WHITE,
                unselectedLabelColor: DEFAULT_WHITE,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                labelPadding: EdgeInsets.only(left: 10),

                tabs: [
                  Tab(text: 'Add Drinks'),
                  Tab(text: 'Leaderboard'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [

                    Container(
                      child: Column(
                        children: [

                        ],
                      ),
                    ),

                    Container(),

                  ],
                ),
              )
            ],
          )
        )
      ),
    );
  }


}
