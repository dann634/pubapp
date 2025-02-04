import 'package:flutter/material.dart';
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
  Drink("Vodka (Smirnoff)", 1.0, "Vodka"),
  Drink("Whiskey (Jack Daniel’s)", 1.0, "Whiskey"),
  Drink("Rum (Captain Morgan)", 1.0, "Rum"),
  Drink("Gin (Gordon’s)", 0.94, "Gin"),
  Drink("Tequila (Jose Cuervo)", 0.95, "Tequila"),
  Drink("Brandy (Hennessy)", 1.0, "Brandy"),
  Drink("Absinthe", 1.38, "Spirit"),
  Drink("Sambuca", 0.95, "Spirit"),
  Drink("Baileys Irish Cream", 0.43, "Cream Liqueur"),
  Drink("Jägermeister", 0.88, "Jager"),
  ];

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

      subList.add(Row(
        children: [
          Text(drink.name,
            style: TextStyle(
              color: DEFAULT_WHITE,
            ),
          )
        ],
      ));

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
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Column(
                        spacing: 10,
                        children: [

                          Expanded(
                            child: SingleChildScrollView(
                              child: ExpansionPanelList(
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


