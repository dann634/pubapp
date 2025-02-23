import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'connection.dart' hide getBACProfile;
import 'localStorage.dart';
import 'utils.dart'; // Assuming this contains your color constants like DEFAULT_ORANGE, DEFAULT_WHITE, etc.

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
    final BACProfile = await getBACProfile();
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

      if (eventId == null) {
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
        actions: [
          IconButton(
            onPressed: () {
              // Open settings
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsWidget(
                    onLeaveEvent: () async {
                      await leaveEvent();
                      checkProfile(); // Refresh the screen after leaving the event
                    },
                    onOptOut: () async {
                      await updateBACProfile(false, null, null);
                      checkProfile(); // Refresh the screen after opting out
                    },
                    onUpdateInfo: (weight, gender) async {
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
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only numbers
            ],
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CupertinoSwitch(
                value: hasAgreed,
                onChanged: (value) {
                  setState(() {
                    hasAgreed = value;
                  });
                },
              ),
              const SizedBox(width: 10),
              const Text(
                "Enable Event Feature",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSubmitting
                ? null // Disable button while submitting
                : () async {
              if (selectedGender == null || weightController.text.isEmpty || !hasAgreed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields and agree to the terms.")),
                );
              } else {
                setState(() {
                  isSubmitting = true; // Show loading state
                });

                try {
                  // Send data to the server
                  print("Updating BAC Profile: true, ${weightController.text}, $selectedGender");
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
                    SnackBar(content: Text("Failed to update info: $e")),
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
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (eventIdController.text.length != 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid 8-digit Event ID.")),
                );
              } else {
                bool success = await joinEvent(int.parse(eventIdController.text));
                if (success) {
                  onJoinOrCreate(); // Refresh the screen
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to join event. Please check the Event ID.")),
                  );
                }
              }
            },
            child: const Text("Join Event"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await createEvent();
              onJoinOrCreate(); // Refresh the screen
            },
            child: const Text("Create Event"),
          ),
        ],
      ),
    );
  }
}

// Event Page Widget (Placeholder)
class EventPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Event Page",
        style: TextStyle(color: Colors.white, fontSize: 24),
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
            title: const Text("Leave Event"),
            onTap: onLeaveEvent,
          ),
          ListTile(
            title: const Text("Opt Out of Events"),
            onTap: onOptOut,
          ),
          ListTile(
            title: const Text("Update Info"),
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
                if (selectedGender == null || weightController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields.")),
                  );
                } else {
                  setState(() {
                    isSubmitting = true; // Show loading state
                  });

                  try {
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
                      SnackBar(content: Text("Failed to update info: $e")),
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