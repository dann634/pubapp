import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils.dart';

class DrinksScreen extends StatefulWidget {
  const DrinksScreen({super.key});

  @override
  State<DrinksScreen> createState() => _DrinksScreenState();
}

class _DrinksScreenState extends State<DrinksScreen> {

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

  Drink("Absinthe", 1.38, "Other"),
  Drink("Sambuca", 0.95, "Other"),
  Drink("Baileys Irish Cream", 0.43, "Other"),
  Drink("Jägermeister", 0.88, "Other"),
  ];

  List<TextEditingController> textControllers = List<TextEditingController>.empty(growable: true);
  List<DrinkTypeRow> tiles = List<DrinkTypeRow>.empty(growable: true);

  void getExpansionWidgets() {
    List<List<Widget>> list = List<List<Widget>>.empty(growable: true);

    String category = allDrinks[0].type;
    List<Widget> subList = List<Widget>.empty(growable: true);

    for(int i = 0; i < allDrinks.length; i++) {

      final drink = allDrinks[i];
      if(category != drink.type) {
        list.add(subList);

        // Add a new DrinkTypeRow for the previous category
        tiles.add(DrinkTypeRow(header: category, content: subList));

        // Reset for the new category
        category = drink.type;
        subList = List<Widget>.empty(growable: true);
      }

      final textController = TextEditingController();
      subList.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drink.name, style: TextStyle(color: DEFAULT_WHITE)),
                  Text("${drink.units} units", style: TextStyle(color: DEFAULT_GREY)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {

                      String currentText = textController.text;
                      if(currentText.isNotEmpty) {
                        int currentNumber = int.parse(currentText);
                        if(currentNumber > 0) {
                          textController.text = (currentNumber - 1).toString();
                        }
                      }

                    },
                    icon: Icon(Icons.remove, color: DEFAULT_WHITE),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: TextField(
                      controller: textController,
                      keyboardType: TextInputType.number,  // Numbers only
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center, // Vertically center the text

                      style: TextStyle(
                        color: DEFAULT_WHITE,
                        fontSize: 15,
                      ), // Text color

                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: DEFAULT_GREY), // Default border color
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: DEFAULT_GREY), // Default border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: DEFAULT_WHITE, width: 2), // White focused border
                        ),
                        contentPadding: EdgeInsets.only(bottom: 10), // Adjust for vertical centering
                      ),

                      cursorColor: DEFAULT_WHITE, // White cursor
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Restrict input to numbers only
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      String currentText = textController.text;
                      if(currentText.isEmpty) {
                        textController.text = "1";
                      } else {
                        int newNumber = int.parse(currentText) + 1;
                        textController.text = newNumber.toString();
                      }
                    },
                    icon: Icon(Icons.add, color: DEFAULT_WHITE),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      textControllers.add(textController);


    }
  }




  @override
  void initState() {
    super.initState();
    getExpansionWidgets();
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
                            onPressed: () {

                              //Get total units and count for each section
                              double totalUnits = 0;
                              final drinkTypeDict = {};
                              for(int i = 0; i < allDrinks.length; i++) {
                                final textController = textControllers[i];
                                String text = textController.text;
                                if(text.isNotEmpty && int.parse(text) > 0) {

                                  int drinkCount = int.parse(text);

                                  final drink = allDrinks[i];

                                  double units = drinkCount * drink.units;
                                  totalUnits += units;


                                  if(drinkTypeDict.containsKey(drink.type)) {
                                    drinkTypeDict[drink.type] += drinkCount;
                                  } else {
                                    //Add to dictionary
                                    drinkTypeDict[drink.type] = drinkCount;
                                  }

                                }
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


