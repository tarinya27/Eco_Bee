import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'algorithm.dart';
import 'feed.dart';
import 'localization.dart';
import 'unit.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  Unit? selectedUnit;
  bool hasNotifications = true; // Simulating notifications
  String? validationMessage; // Validation message

  final List<String> notifications = [
    "Notification 1: Colombo hive 1 feeder is empty",
    "Notification 2: Galle hive 2 automation started",
    "Notification 3: automation finished",
  ];

  @override
  Widget build(BuildContext context) {
    // Listen to user data stream from Firebase
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance
              .ref('users/${FirebaseAuth.instance.currentUser?.uid}')
              .onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text(Localization.errorLoadingData));
        }
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) { // Show message if no user data
          return const Center(child: Text(Localization.noUserDataAvailable));
        }
        final userData =
            snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;  // Extract user data

        Localization localization = englishLocalization;
        if (userData?['language'] == 'Sinhala') {
          localization = sinhalaLocalization;
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFE59C15),
            title: Text(localization.automation),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back
              },
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),

                    // Show notification bottom sheet
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.notification_important,
                                ),
                                title: Text(notifications[index]),
                              );
                            },
                          );
                        },
                      );
                      setState(() {
                        hasNotifications = false; // Clear notifications
                      });
                    },
                  ),
                     // Red dot for new notifications
                  if (hasNotifications)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fetch and display units owned by the user
                StreamBuilder(
                  stream:
                      FirebaseDatabase.instance
                          .ref('units')
                          .orderByChild('owner')
                          .equalTo(FirebaseAuth.instance.currentUser?.uid)
                          .onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final unitsData =
                        snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                    // Map units from Firebase to local Unit objects
                    final List<Unit> units =
                        unitsData != null
                            ? unitsData.entries
                                .map(
                                  (entry) => Unit(
                                    id: entry.key,
                                    nickname: entry.value['nickname'],
                                    beeSpecies: entry.value['beeSpecies'],
                                    numFrames: entry.value['numFrames'],
                                    hiveSize: entry.value['hiveSize'],
                                    province: entry.value['province'],
                                    district: entry.value['district'],
                                  ),
                                )
                                .toList()
                            : [];
                    if (units.isEmpty) {    // Show message if no units
                      return Center(
                        child: Text(
                          localization.noUnitsFound,
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }
                     // Unit selection dropdown
                    return DropdownButtonFormField<Unit>(
                      decoration: InputDecoration(
                        labelText: localization.selectTheUnit,
                      ),
                      value: selectedUnit,
                      items:
                          units
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit.nickname),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                 // Display validation or error message
                if (validationMessage != null)
                  Center(
                    child: Text(
                      validationMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Start automation button
                Center(
                  child: ElevatedButton(
                    onPressed:
                        (selectedUnit != null)
                            ? () async {
                              setState(() {
                                validationMessage =
                                    null; // Clear validation message
                              });
                              await startAutomation(
                                selectedUnit!,
                                localization,
                              ); // Start the automation process
                            }
                            : () {
                              setState(() {
                                validationMessage = localization.noUnitSelected;
                              });
                            },
                    child: Text(localization.startAutomation),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // Main logic for triggering automation
  Future<void> startAutomation(Unit unit, Localization localization) async {
    final id = unit.id;
    dynamic record;
    // Get latest sensor data
    final dataSnapshot =
        await FirebaseDatabase.instance
            .ref('data/$id')
            .orderByKey()
            .limitToLast(1)
            .once();
    record = dataSnapshot.snapshot.value;
    // Check for missing data
    if (record == null) {
      setState(() {
        validationMessage = localization.noDataAvailable;
      });
      return;
    }
    // Extract sensor data
    Map data = record.values.first as Map;
 
    // Get last feeding history
    final historySnapshot =
        await FirebaseDatabase.instance
            .ref('history/$id')
            .orderByKey()
            .limitToLast(1)
            .once();
    record = historySnapshot.snapshot.value;
    (DateTime, double)? lastFeeding;
    if (record != null) {
      Map history = record.values.first as Map;
      lastFeeding = (
        DateTime.fromMillisecondsSinceEpoch(history['timestamp'] * 1000),
        history['quantity'],
      );
    }

      // Assess feeding need
    (String, double) feed = assessFeeding(
      hiveHumidity: data['humidity'],
      externalTemp: data['temperature'],
      raining: data['rainIntensity'] > 0,
      currentTime: DateTime.now(),
      numFrames: unit.numFrames,
      beeSpecies: unit.beeSpecies,
      hiveSize: unit.hiveSize,
      lastFeeding: lastFeeding,
    );

    // If feeding not required, show reason
    if (feed.$2 == 0) {
      setState(() {
        validationMessage = feed.$1;
      });
    } else {
      // Otherwise, send command to feeder
      sendFeedingCommand(id, 'manual', feed.$2);
    }
  }
}
