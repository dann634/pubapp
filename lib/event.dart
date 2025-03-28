import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pubapp/widgets/UnitsGraph.dart';
import 'classes/Drink.dart';
import 'connection.dart';
import 'localStorage.dart';
import 'utils.dart'; // Assuming this contains your color constants like DEFAULT_ORANGE, DEFAULT_WHITE, etc.
//graph imports
import 'dart:async';


class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool hasLoaded = false;
  Widget? currentScreen;

  @override
  void initState() {
    super.initState();
    checkProfile();
  }

  Future<void> checkProfile() async {
    print("Checking profile...");
    final BACProfile = await getBACProfileLocal();
    print("BAC Profile: $BACProfile");

    if (BACProfile.isEmpty || BACProfile["isEnabled"] == false) {
      // User has not opted into events feature
      print("User has not opted in. Showing OptInWidget...");
      setState(() {
        currentScreen = OptInWidget(
          onOptIn: () {
            print("User opted in. Refreshing profile...");
            checkProfile();
          },
        );
        hasLoaded = true;
      });
    } else {
      // User has opted into events feature
      print("User has opted in. Checking event ID...");
      int? eventId = await getEventId();
      print("Event ID: $eventId");

      if (eventId == null || eventId == -1) {

        // User is not in an event
        print("User is not in an event. Showing JoinCreateEventWidget...");
        setState(() {
          currentScreen = JoinCreateEventWidget(
            onJoinOrCreate: () {
              print("User joined or created an event. Refreshing profile...");
              checkProfile();
            },
          );
          hasLoaded = true;
        });
      } else {
        // User is in an event
        print("User is in an event. Showing EventPageWidget...");
        setState(() {
          currentScreen = EventPageWidget(); // Placeholder for the event page
          hasLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        centerTitle: true,
        // Hide the settings icon if the current screen is OptInWidget
        actions: currentScreen is OptInWidget
            ? []
            : [
          IconButton(
            onPressed: () {
              // Open settings
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsWidget(
                    onLeaveEvent: () async {
                      await leaveEvent();
                      saveEventId(-1);
                      await resetLocalEventDrinkList();
                      await saveEventLastAccess("01-01-2020-12-00-00"); //Resets last access to beginning
                      Navigator.pop(context);
                      checkProfile(); // Refresh the screen after leaving the event
                    },
                    onOptOut: () async {
                      await deleteBACProfile();
                      await leaveEvent();
                      await saveEventId(-1);
                      await resetLocalEventDrinkList();
                      await saveBACProfile(false, -1, "null");
                      await leaveEvent();
                      saveEventId(-1);
                      checkProfile(); // Refresh the screen after opting out
                      // Navigate back to the default page
                      Navigator.pop(context); // Close the settings page
                    },
                    onUpdateInfo: (weight, gender) async {
                      saveBACProfile(true, weight, gender);
                      await updateBACProfile(true, weight, gender);
                      checkProfile(); // Refresh the screen after updating info
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: hasLoaded
          ? currentScreen
          : const Center(
        child: CircularProgressIndicator(
          color: DEFAULT_WHITE,
        ),
      ),
    );
  }
}

// Opt-In Widget
class OptInWidget extends StatefulWidget {
  final VoidCallback onOptIn;

  const OptInWidget({required this.onOptIn, super.key});

  @override
  State<OptInWidget> createState() => _OptInWidgetState();
}

class _OptInWidgetState extends State<OptInWidget> {
  String? selectedGender;
  final TextEditingController weightController = TextEditingController();
  bool hasAgreed = false;
  bool isSubmitting = false; // Track submission state

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "**NOTE PLEASE READ**\nBy enabling the event feature you acknowledge that the Blood Alcohol Measurement (graph) is simply an estimate for fun and should not be used as a real measurement of the users sobriety.",
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedGender = "Male";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedGender == "Male" ? DEFAULT_ORANGE : DEFAULT_WHITE,
                  ),
                  child: const Text(
                    "Male",
                    style: TextStyle(color: DEFAULT_BLACK, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedGender = "Female";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedGender == "Female" ? DEFAULT_ORANGE : DEFAULT_WHITE,
                  ),
                  child: const Text(
                    "Female",
                    style: TextStyle(color: DEFAULT_BLACK, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number, // Numeric keyboard
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only numbers
            ],
            decoration: const InputDecoration(
              labelText: "Weight (KG)",
              labelStyle: TextStyle(color: Colors.white),
              hintText: "Enter your weight",
              hintStyle: TextStyle(color: Colors.white54),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: DEFAULT_ORANGE),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: DEFAULT_ORANGE),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Enable Event Feature",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              CupertinoSwitch(
                value: hasAgreed,
                onChanged: (value) {
                  setState(() {
                    hasAgreed = value;
                  });
                },
              ),

            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSubmitting
                ? null // Disable button while submitting
                : () async {
              // Validate weight
              final weight = double.tryParse(weightController.text);
              if (weight == null || weight <= 0 || weight > 400) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a valid weight between 1 and 400 kg.",style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.red, // Optional: Set background color for error
                  ),
                );
                return; // Exit the function if weight is invalid
              }

              if (selectedGender == null || weightController.text.isEmpty || !hasAgreed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields and agree to the terms.",style: TextStyle(fontWeight: FontWeight.bold),),backgroundColor: Colors.red),
                );
              } else {
                setState(() {
                  isSubmitting = true; // Show loading state
                });

                try {
                  // Send data to the server
                  print("Updating BAC Profile: true, ${weightController.text}, $selectedGender");
                  saveBACProfile(true, double.parse(weightController.text), selectedGender!);
                  await updateBACProfile(
                    true, // isEnabled
                    double.parse(weightController.text), // weight
                    selectedGender!, // gender
                  );

                  // Call the callback to update the parent widget
                  widget.onOptIn(); // Refresh the screen
                } catch (e) {
                  // Handle errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update info: $e",style: TextStyle(fontWeight: FontWeight.bold)),backgroundColor: Colors.red),
                  );
                } finally {
                  setState(() {
                    isSubmitting = false; // Reset loading state
                  });
                }
              }
            },
            child: isSubmitting
                ? const CircularProgressIndicator() // Show loading indicator
                : const Text("Submit", style: TextStyle(color: DEFAULT_BLACK)),
          ),
        ],
      ),
    );
  }
}

// Join/Create Event Widget
class JoinCreateEventWidget extends StatelessWidget {
  final VoidCallback onJoinOrCreate;

  const JoinCreateEventWidget({required this.onJoinOrCreate, super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController eventIdController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: eventIdController,
            keyboardType: TextInputType.number, // Numeric keyboard
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only numbers
            ],
            decoration: const InputDecoration(
              labelText: "Event ID",
              labelStyle: TextStyle(color: Colors.white),
              hintText: "Enter 8-digit Event ID",
              hintStyle: TextStyle(color: Colors.white54),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: DEFAULT_ORANGE),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: DEFAULT_ORANGE),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                fixedSize: Size.fromWidth(200)
            ),
            onPressed: () async {
              if (eventIdController.text.length != 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid 8-digit Event ID.",style: TextStyle(fontWeight: FontWeight.bold)),backgroundColor: Colors.red),
                );
              } else {
                List<dynamic> response = await joinEvent(int.parse(eventIdController.text));
                if (response[0]) {
                  await saveEventLastAccess(response[1]);
                  onJoinOrCreate(); // Refresh the screen
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to join event. Please check the Event ID.",style: TextStyle(fontWeight: FontWeight.bold)),backgroundColor: Colors.red),
                  );
                }
              }
            },

            child: const Text("Join Event", style: TextStyle(color: DEFAULT_BLACK, fontWeight: FontWeight.bold,),),
          ),
          const SizedBox(height: 20,),
          const Text("or",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final eventID =  await createEvent();
              saveEventId(eventID);

              //Get Local Time
              DateTime dateTime = DateTime.now();
              String formattedDate = DateFormat("dd-MM-yyyy-HH-mm-ss").format(dateTime);
              saveEventLastAccess(formattedDate);
              onJoinOrCreate(); // Refresh the screen
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromWidth(200)
            ),
            child: const Text("Create Event", style: TextStyle(color: DEFAULT_BLACK, fontWeight: FontWeight.bold,)),
          ),
        ],
      ),
    );
  }
}

// Event Page Widget

class EventPageWidget extends StatefulWidget {
  @override
  _EventPageWidgetState createState() => _EventPageWidgetState();
}

class _EventPageWidgetState extends State<EventPageWidget> {
  int? eventId;
  List<(String, double)> bacList = []; // List of tuples (records)

  List<Drink> drinkList = List.empty(growable: true);
  List<Widget> widgetDrinkList = List.empty(growable: true);
  Widget graphWidget = CircularProgressIndicator(color: Colors.white);

  @override
  void initState() {
    super.initState();
    loadEventData();
  }

  Future<void> loadEventData() async {
    final id = await getEventId();
    eventId = id;
    // Manually add some test data
    //final list = await getEventBACList();

    drinkList.clear();
    List<dynamic> newDrinkList = await getEventDrinkList();
    if(newDrinkList.isEmpty) {
      setState(() {});
      return;
    }


    for(int i = newDrinkList.length-1; i >= 0; i--) {
      final name = newDrinkList[i][0];
      final fullname = newDrinkList[i][1];
      final type = newDrinkList[i][3];
      final units = newDrinkList[i][2];
      final time = newDrinkList[i][4];
      DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(time);
      String formattedDate = DateFormat("EEE, dd MMM HH:mm").format(dateTime);
      drinkList.insert(0, Drink(name, fullname, type, units, formattedDate));
    }
    await buildDrinkList();
  }


  Future<void> buildDrinkList() async {

    widgetDrinkList.clear();

    widgetDrinkList.add(Divider(color: DEFAULT_WHITE));
    for(int i = 0; i < drinkList.length; i++) {
      Drink drink = drinkList[i];
      widgetDrinkList.add(Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drink.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(drink.fullname),
                Spacer(),
                Text(drink.time),
              ],
            ),

            Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${drink.units} units",
                  style: TextStyle(
                    fontSize: 18
                  ),
                ),
                Text(drink.type),
              ],
            ),
          ],
        ),
      ));
      widgetDrinkList.add(Divider(color: DEFAULT_WHITE));
    }

    graphWidget = UnitsGraph(drinkList: drinkList);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadEventData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 130,
                maxHeight: MediaQuery.of(context).size.height - 130,
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Event ID: ${eventId ?? "Loading..."}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: graphWidget,
                ),

                Expanded(
                  child: SingleChildScrollView(

                    child: Column(
                      children: widgetDrinkList,
                    ),
                  ),
                )
              ],
            ),
            ),

        )
      )
    );
  }
}

// Settings Widget
class SettingsWidget extends StatelessWidget {
  final VoidCallback onLeaveEvent;
  final VoidCallback onOptOut;
  final Function(double, String) onUpdateInfo;

  const SettingsWidget({
    required this.onLeaveEvent,
    required this.onOptOut,
    required this.onUpdateInfo,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(0),

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 15,
                  children: [
                    const Icon(Icons.exit_to_app),
                    const Text("Leave Event")
                  ],
                ),

                Icon(Icons.keyboard_arrow_right_outlined)
              ],
            ),
            textColor: DEFAULT_WHITE,
            iconColor: DEFAULT_WHITE,
            onTap: onLeaveEvent,
          ),
          // ListTile(
          //   contentPadding: EdgeInsets.all(0),
          //
          //   title: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Row(
          //         spacing: 15,
          //         children: [
          //           const Icon(Icons.block),
          //           const Text("Opt Out of Events")
          //         ],
          //       ),
          //
          //       Icon(Icons.keyboard_arrow_right_outlined)
          //     ],
          //   ),
          //   textColor: DEFAULT_WHITE,
          //   iconColor: DEFAULT_WHITE,
          //   onTap: onOptOut,
          // ),
          // ListTile(
          //   contentPadding: EdgeInsets.all(0),
          //
          //   title: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Row(
          //         spacing: 15,
          //         children: [
          //           const Icon(Icons.autorenew),
          //           const Text("Update Info")
          //         ],
          //       ),
          //
          //       Icon(Icons.keyboard_arrow_right_outlined)
          //     ],
          //   ),
          //   textColor: DEFAULT_WHITE,
          //   iconColor: DEFAULT_WHITE,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => UpdateInfoWidget(onUpdateInfo: onUpdateInfo),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}

// Update Info Widget
class UpdateInfoWidget extends StatefulWidget {
  final Function(double, String) onUpdateInfo;

  const UpdateInfoWidget({required this.onUpdateInfo, super.key});

  @override
  State<UpdateInfoWidget> createState() => _UpdateInfoWidgetState();
}

class _UpdateInfoWidgetState extends State<UpdateInfoWidget> {
  String? selectedGender;
  final TextEditingController weightController = TextEditingController();
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Info"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedGender = "Male";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedGender == "Male" ? DEFAULT_ORANGE : DEFAULT_WHITE,
                    ),
                    child: const Text(
                      "Male",
                      style: TextStyle(color: DEFAULT_BLACK, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedGender = "Female";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedGender == "Female" ? DEFAULT_ORANGE : DEFAULT_WHITE,
                    ),
                    child: const Text(
                      "Female",
                      style: TextStyle(color: DEFAULT_BLACK, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: "Weight (KG)",
                labelStyle: TextStyle(color: Colors.white),
                hintText: "Enter your weight",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: DEFAULT_ORANGE),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: DEFAULT_ORANGE),
                ),
              ),
              keyboardType: TextInputType.number, // Numeric keyboard
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allow only numbers
              ],
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null // Disable button while submitting
                  : () async {
                // Validate weight
                final weight = double.tryParse(weightController.text);
                if (weight == null || weight <= 0 || weight > 400) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid weight between 1 and 400 kg.",style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.red, // Optional: Set background color for error
                    ),
                  );
                  return; // Exit the function if weight is invalid
                }

                if (selectedGender == null || weightController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields.",style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.red,),

                  );
                } else {
                  setState(() {
                    isSubmitting = true; // Show loading state
                  });

                  try {
                    saveBACProfile(true, double.parse(weightController.text), selectedGender!);
                    // Send data to the server
                    await updateBACProfile(
                      true, // isEnabled
                      double.parse(weightController.text), // weight
                      selectedGender!, // gender
                    );

                    // Call the callback to update the parent widget
                    widget.onUpdateInfo(
                      double.parse(weightController.text),
                      selectedGender!,
                    );

                    // Navigate back to the previous screen
                    Navigator.pop(context);
                  } catch (e) {
                    // Handle errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to update info: $e",style: TextStyle(fontWeight: FontWeight.bold)),backgroundColor: Colors.red),
                    );
                  } finally {
                    setState(() {
                      isSubmitting = false; // Reset loading state
                    });
                  }
                }
              },
              child: isSubmitting
                  ? const CircularProgressIndicator() // Show loading indicator
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

