import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'connection.dart';
import 'localStorage.dart';
import 'utils.dart'; // Assuming this contains your color constants like DEFAULT_ORANGE, DEFAULT_WHITE, etc.
//graph imports
import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
                      Navigator.pop(context);
                      checkProfile(); // Refresh the screen after leaving the event
                    },
                    onOptOut: () async {
                      await deleteBACProfile();
                      await leaveEvent();
                      await saveEventId(-1);
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
                bool success = await joinEvent(int.parse(eventIdController.text));
                if (success) {
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
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    loadEventData();
  }

  Future<void> loadEventData() async {
    final id = await getEventId();
    // Manually add some test data
    final list = await getEventBACList();
    setState(() {
      eventId = id;
      bacList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: bacList.isEmpty
                  ? const Center(
                child: Text(
                  'No BAC data available',
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blueGrey, // Set tooltip background color
                      tooltipMargin: -10,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final user = bacList[groupIndex];
                        return BarTooltipItem(
                          '${user.$1}\n', // Access the first field (name)
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'BAC: ${user.$2}', // Access the second field (BAC value)
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            barTouchResponse == null ||
                            barTouchResponse.spot == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < bacList.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                bacList[index].$1, // Access the first field (name)
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 38,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: bacList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final user = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: user.$2, // Access the second field (BAC value)
                          color: touchedIndex == index
                              ? Colors.orange
                              : Colors.blue,
                          width: 22,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 0.3, // Adjust this based on your max BAC value
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                      ],
                      showingTooltipIndicators: touchedIndex == index ? [0] : [],
                    );
                  }).toList(),
                  gridData: FlGridData(
                    show: false,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
          ListTile(
            contentPadding: EdgeInsets.all(0),

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 15,
                  children: [
                    const Icon(Icons.block),
                    const Text("Opt Out of Events")
                  ],
                ),

                Icon(Icons.keyboard_arrow_right_outlined)
              ],
            ),
            textColor: DEFAULT_WHITE,
            iconColor: DEFAULT_WHITE,
            onTap: onOptOut,
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 15,
                  children: [
                    const Icon(Icons.autorenew),
                    const Text("Update Info")
                  ],
                ),

                Icon(Icons.keyboard_arrow_right_outlined)
              ],
            ),
            textColor: DEFAULT_WHITE,
            iconColor: DEFAULT_WHITE,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateInfoWidget(onUpdateInfo: onUpdateInfo),
                ),
              );
            },
          ),
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