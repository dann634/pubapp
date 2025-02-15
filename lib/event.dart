import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

bool hasAgreed = false;


class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  bool hasLoaded = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: Text("Event",
          style: TextStyle(
            color: DEFAULT_WHITE,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => EventSettingsScreen()));
              setState(() {});
            },
            icon: Icon(Icons.settings_outlined),
          )
        ],
      ),
      
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          spacing: 20,
          children: [

            Text("**NOTE PLEASE READ** By enabling the event feature you acknowledge that the Blood Alcohol Measurement (graph) is simply an estimate for fun "
                "and should not be used as a real measurement of the users sobriety."),


            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white10,
                border: Border.all(color: Colors.black)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Enable Event Screen",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  CupertinoSwitch(
                    value: hasAgreed,
                    onChanged: (value) {
                      setState(() {
                        hasAgreed = !hasAgreed;
                      });
                    },
                  )
                ],
              ),
            ),

            Text("Events can be turned off any at time in the Event Settings (top right)",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),

    );
  }
}

class EventSettingsScreen extends StatefulWidget {
  const EventSettingsScreen({super.key});

  @override
  State<EventSettingsScreen> createState() => _EventSettingsScreenState();
}

class _EventSettingsScreenState extends State<EventSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "Event Screen"),
      body: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20
        ),
        child: Column(

          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white10,
                  border: Border.all(color: Colors.black)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Enable Event Screen",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  CupertinoSwitch(
                    value: hasAgreed,
                    onChanged: (value) {
                      setState(() {
                        hasAgreed = !hasAgreed;
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

