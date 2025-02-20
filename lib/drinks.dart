import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pubapp/localStorage.dart';
import 'utils.dart';
import 'connection.dart';

List<Drink> allDrinks = [
  // Beers
  Drink("Budweiser", 2.84, "Beer"),
  Drink("Heineken", 2.84, "Beer"),
  Drink("Stella Artois", 2.95, "Beer"),
  Drink("Corona Extra", 2.61, "Beer"),
  Drink("Guinness Draught", 2.39, "Beer"),
  Drink("Carlsberg", 2.16, "Beer"),
  Drink("Peroni Nastro Azzurro", 2.90, "Beer"),
  Drink("Beck’s", 2.84, "Beer"),
  Drink("Kronenbourg 1664", 2.84, "Beer"),
  Drink("Fosters", 2.27, "Beer"),
  Drink("Coors Light", 2.39, "Beer"),
  Drink("Amstel", 2.33, "Beer"),

  // Ciders
  Drink("Strongbow Original", 2.50, "Cider"),
  Drink("Strongbow Dark Fruit", 2.05, "Cider"),
  Drink("Magners Original", 2.84, "Cider"),
  Drink("Bulmers Original", 2.61, "Cider"),
  Drink("Thatchers Gold", 2.95, "Cider"),
  Drink("Rekorderlig Strawberry-Lime", 2.50, "Cider"),
  Drink("Kopparberg Pear", 2.50, "Cider"),
  Drink("Aspall Cyder", 3.07, "Cider"),
  Drink("Old Mout Berries & Cherries", 2.50, "Cider"),
  Drink("Westons Stowford Press", 2.84, "Cider"),
  Drink("Somersby Apple", 2.50, "Cider"),

  // Spirits
  Drink("Smirnoff", 1.0, "Vodka"),
  Drink("Jack Daniel’s", 1.0, "Whiskey"),
  Drink("Captain Morgan", 1.0, "Rum"),
  Drink("Gordon’s", 0.94, "Gin"),
  Drink("Jose Cuervo", 0.95, "Tequila"),
  Drink("Hennessy", 1.0, "Brandy"),

  //Other Spirits
  Drink("Absinthe", 1.38, "Other"),
  Drink("Sambuca", 0.95, "Other"),
  Drink("Baileys Irish Cream", 0.43, "Other"),
  Drink("Jägermeister", 0.88, "Other"),
];

//Only generate them once
List<DrinkTypeRow> tiles = List<DrinkTypeRow>.empty(growable: true);
List<TextEditingController> textControllers = List.generate(allDrinks.length, (_) => TextEditingController());


class DrinksScreen extends StatefulWidget {
  const DrinksScreen({super.key});

  @override
  State<DrinksScreen> createState() => _DrinksScreenState();
}

class _DrinksScreenState extends State<DrinksScreen> {

  String _selectedTime = "Week";
  List<Widget> leaderboardWidgets = List<Widget>.empty(growable: true);


  @override
  void initState() {
    super.initState();
    _generateDrinkTiles();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadLeaderboard();
    });
  }

  void _generateDrinkTiles() {
    // Group drinks by category using a map for O(n) efficiency
    final Map<String, List<Drink>> drinksByCategory = {};
    for (final drink in allDrinks) {
      drinksByCategory.putIfAbsent(drink.type, () => []).add(drink);
    }

    // Create DrinkTypeRow widgets

    if(tiles.isNotEmpty) {
      return;
    }

    for (final category in drinksByCategory.keys) {
      final drinks = drinksByCategory[category]!;
      final drinkWidgets = drinks.map((drink) => _buildDrinkRow(drink)).toList();
      tiles.add(DrinkTypeRow(header: category, content: drinkWidgets));
    }
  }

  Widget _buildDrinkRow(Drink drink) {
    final textController = textControllers[allDrinks.indexOf(drink)]; // Use index to get correct controller
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drink.name,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(color: DEFAULT_WHITE)
                ),
                Text("${drink.units} units", style: const TextStyle(color: DEFAULT_GREY)),
              ],
            ),
          ),
          Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _decrementDrinkCount(textController);
                },
                icon: const Icon(Icons.remove, color: DEFAULT_WHITE),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: TextField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(color: DEFAULT_WHITE, fontSize: 15),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: DEFAULT_GREY),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: DEFAULT_GREY),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: DEFAULT_WHITE, width: 2),
                    ),
                    contentPadding: const EdgeInsets.only(bottom: 10),
                  ),
                  cursorColor: DEFAULT_WHITE,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              IconButton(
                onPressed: () {
                  _incrementDrinkCount(textController);
                },
                icon: const Icon(Icons.add, color: DEFAULT_WHITE),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _decrementDrinkCount(TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      int currentNumber = int.parse(controller.text);
      if (currentNumber > 0) {
        controller.text = (currentNumber - 1).toString();
      }
    }
  }

  void _incrementDrinkCount(TextEditingController controller) {
    if (controller.text.isEmpty) {
      controller.text = "1";
    } else {
      int newNumber = int.parse(controller.text) + 1;
      controller.text = newNumber.toString();
    }
  }

  void loadLeaderboard() async {

    leaderboardWidgets.clear();

    Map<String, List<dynamic>> friendMap = {};
    final data = await getLeaderboard(); //Get all friend data

    Map<String, int> monthMap = {
      "Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6,
      "Jul": 7, "Aug": 8, "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12
    };


    DateTime currentTime = DateTime.now();
    DateTime? cutoffTime;
    switch(_selectedTime) {
      case "Day":
        cutoffTime = currentTime.subtract(Duration(days: 1));
        break;
      case "Week":
        cutoffTime = currentTime.subtract(Duration(days: 7));
        break;
      case "Month":
        cutoffTime = currentTime.subtract(Duration(days: 31));
        break;
      case "Year":
        cutoffTime = currentTime.subtract(Duration(days : 365));
        break;
    }

    for(int i = 0; i < data.length; i++) {
      final entry = data[i];

      //Format Time
      final splitDate = entry[3].toString().split(" ");
      final day = int.parse(splitDate[1]);
      final month = monthMap[splitDate[2]] ?? 0;
      final year = int.parse(splitDate[3]);
      final splitTime = splitDate[4].split(":");
      final hour = int.parse(splitTime[0]);
      final minute = int.parse(splitTime[1]);
      final second = int.parse(splitTime[2]);
      DateTime date = DateTime(year, month, day, hour, minute, second);

      if(date.isBefore(cutoffTime!)) {
        continue;
      }

      String username = entry[0];
      double units = double.parse(entry[2]);
      if(friendMap[username] == null) {
        String fullname = entry[1];
        friendMap[username] = [fullname, units];
      } else {
        friendMap[username]![1] += units;
      }
    }

    if(data.isEmpty) {
      leaderboardWidgets.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Wait for your friends to add some drinks!",
            style: TextStyle(
              fontSize: 18,
            ),
          )
        ],
      ));
      setState(() {});
      return;
    }

    //Add Me to List
    double userUnits = await getUnits(_selectedTime.toLowerCase());
    if(username != null) {
      friendMap[username!] = [fullName, userUnits];
    }

    //Order friends
    List<String> rankings = List<String>.empty(growable: true);
    for (var key in friendMap.keys) {
      double units = friendMap[key]![1];

      if (rankings.isEmpty) {
        // Add the first element when the list is empty
        rankings.add(key);
      } else {
        bool inserted = false; // Flag to track if we inserted the key
        for (int counter = 0; counter < rankings.length; counter++) {
          // Check if the units of the current friend are greater or equal to the units of the key
          if (friendMap[rankings[counter]]![1] <= units) {
            rankings.insert(counter, key); // Insert the key in the correct position
            inserted = true; // Set the flag to true once the key is inserted
            break; // Break out of the loop since we have inserted the key
          }
        }

        // If the key was not inserted (meaning it should go at the end), add it at the last position
        if (!inserted) {
          rankings.add(key);
        }
      }
    }

    leaderboardWidgets.add(Divider(color: Colors.white24));
    for(int i = 0; i < rankings.length; i++) {
      String username = rankings[i];
      final data = friendMap[username];
      double units = data![1];
      leaderboardWidgets.add(Container(

          padding: EdgeInsets.symmetric(horizontal: 10),

          child : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Row(
                spacing: 20,
                children: [
                  Text("${i+1}.",
                    style: TextStyle(
                        fontSize: 17
                    ),

                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(data[0],
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Text("${units.toStringAsFixed(2)} units",
                style: TextStyle(
                  fontSize: 17,
                ),
              )


            ],
          )
      ));
      leaderboardWidgets.add(Divider(color: Colors.white24));
    }




    setState(() {});
    //Only show friend data
  }

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
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Column(
                        spacing: 10,
                        children: [

                          Expanded(
                            child: SingleChildScrollView(
                              child: ExpansionPanelList(
                                expandedHeaderPadding: EdgeInsets.zero,
                                materialGapSize: 0,
                                expandIconColor: DEFAULT_WHITE,
                                dividerColor: DEFAULT_GREY,
                                expansionCallback: (int index, bool isExpanded) {
                                  setState(() {
                                    tiles[index].isExpanded = isExpanded;
                                  });
                                },
                                children: tiles.map((item) {
                                  return ExpansionPanel(
                                    canTapOnHeader: true,
                                    backgroundColor: DEFAULT_BLACK,
                                    headerBuilder: (context, isExpanded) {
                                      return ListTile(

                                        contentPadding: EdgeInsets.symmetric(

                                        ),
                                        iconColor: DEFAULT_WHITE,
                                        title: Text(
                                            item.header,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: DEFAULT_WHITE,
                                            )
                                        ),
                                      );
                                    },
                                    body: Column(
                                      children: item.content, // Custom widgets inside each panel
                                    ),
                                    isExpanded: item.isExpanded,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),


                          TextButton(
                            onPressed: () async {

                              //Get total units and count for each section
                              List<String> drinksList = List<String>.empty(growable: true);
                              List<double> unitsList = List<double>.empty(growable: true);
                              double totalUnits = 0;
                              for(int i = 0; i < allDrinks.length; i++) {
                                final textController = textControllers[i];
                                String text = textController.text;
                                if(text.isNotEmpty && int.parse(text) > 0) {

                                  int drinkCount = int.parse(text);

                                  final drink = allDrinks[i];

                                  for(int j = 0; j < drinkCount; j++) {
                                    drinksList.add(drink.type);
                                    unitsList.add(drink.units);
                                    totalUnits += drink.units;
                                  }

                                }
                              }

                              if(drinksList.isNotEmpty) {
                                //Update local record
                                double? monthlyUnits = await getMonthlyUnits();
                                if(monthlyUnits != null) {
                                  await saveMonthlyUnits(monthlyUnits + totalUnits);
                                }
                                
                                await addDrinksToProfile(unitsList, drinksList); //Update server record
                              }
                              //Send data to server to update profile


                            },
                            style: TextButton.styleFrom(
                              fixedSize: Size(MediaQuery.of(context).size.width*0.9, 50),
                              backgroundColor: DEFAULT_ORANGE,  // Background color to white
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),  // Rounded corners
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20), // Padding for better button size
                              foregroundColor: DEFAULT_BLACK,
                            ),
                            child: Text("Add",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17
                              ),
                            ),
                          )

                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              getTimeChangeButton("Day"),
                              getTimeChangeButton("Week"),
                              getTimeChangeButton("Month"),
                              getTimeChangeButton("Year"),



                            ],
                          ),

                          SingleChildScrollView(
                            child: Column(
                              children: leaderboardWidgets,
                            ),
                          )
                        ],
                      ),
                    ),

                  ],
                ),
              )
            ],
          )
        )
      ),
    );
  }


  TextButton getTimeChangeButton(String time) {
    double width = MediaQuery.of(context).size.width;
    return TextButton(
      onPressed: () {
        _selectedTime = time;
        loadLeaderboard();
      },

      style: TextButton.styleFrom(
        backgroundColor: _selectedTime == time ? Colors.white70 : Colors.grey[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        fixedSize: Size.fromWidth(width * 0.18),
      ),

      child: Text(time,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: width * 0.035,
        ),
      ),

    );
  }


}

class Drink {
  String name;
  double units;
  String type;

  Drink(this.name, this.units, this.type);
}

class DrinkTypeRow {
  String header;
  List<Widget> content;
  bool isExpanded;

  DrinkTypeRow({required this.header, required this.content, this.isExpanded = false});
}


