import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'algorithm.dart';
import 'notifications.dart';
import 'unit.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool timeout = task.timeout;

  // If task exceeds the allowed execution time, finish and return.
  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  try {
    await Firebase.initializeApp();
    final user = FirebaseAuth.instance.currentUser;  // Check the currently logged-in user.

    if (user == null) {
      print("No user logged in.");
      BackgroundFetch.finish(taskId);
      return;
    }

    // Fetch all units that belong to the current user from the database.
    DataSnapshot unitsSnapshot =
        await FirebaseDatabase.instance
            .ref('units')
            .orderByChild('owner')
            .equalTo(user.uid)
            .get();
 
     // If no units exist, terminate task.
    if (!unitsSnapshot.exists) {
      print("User does not have any units.");
      BackgroundFetch.finish(taskId);
      return;
    }

    // Convert the snapshot into a list of Unit objects.
    final unitsData = unitsSnapshot.value as Map<dynamic, dynamic>?;
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

    for (Unit unit in units) {
      Map<String, dynamic>? data;

      // Fetch the most recent sensor data for the unit
      final dataRef = FirebaseDatabase.instance.ref("data/${unit.id}"); 
      final dataSnapshot = await dataRef.orderByKey().limitToLast(1).get();
      if (!dataSnapshot.exists) continue;

      // Parse the latest data entry
      if (dataSnapshot.value is Map) {
        final rawMap = dataSnapshot.value as Map;
        final latestDataEntry = rawMap.values.first;

        if (latestDataEntry is Map) {
          data = Map<String, dynamic>.from(latestDataEntry);
        } else {
          throw "Latest data is not a map: $latestDataEntry";
        }
      } else {
        throw "Data snapshot value is not a map: ${dataSnapshot.value}";
      }

      (DateTime, double)? lastFeeding;

      // Fetch the most recent feeding history for the unit
      final feedRef = FirebaseDatabase.instance.ref("history/${unit.id}");
      final feedSnapshot = await feedRef.orderByKey().limitToLast(1).get();
      if (feedSnapshot.exists) {
        if (feedSnapshot.value is Map) {
          final rawMap = feedSnapshot.value as Map;
          final latestFeedEntry = rawMap.values.first;
          if (latestFeedEntry is Map) {
            lastFeeding = (
              DateTime.fromMillisecondsSinceEpoch(
                latestFeedEntry['timestamp'] * 1000,
              ),
              latestFeedEntry['quantity'],
            );
          } else {
            print("Latest feed is not a map: $latestFeedEntry");
          }
        } else {
          print("Feed snapshot value is not a map: ${feedSnapshot.value}");
        }
      }
  
      // Use algorithm to decide if feeding is needed and the quantity.
      final (message, quantity) = assessFeeding(
        hiveHumidity: data['humidity'],
        externalTemp: data['temperature'],
        raining: data['rainIntensity'] > 0,
        currentTime: DateTime.now(),
        hiveSize: unit.hiveSize,
        beeSpecies: unit.beeSpecies,
        numFrames: unit.numFrames,
        lastFeeding: lastFeeding,
      );
      print("Message: $message, Quantity: $quantity");
 
      // Show notification if feeding is needed
      if (quantity > 0) {
        await showFeedingNotification(unit, quantity);
      }
    }
  } catch (e, stacktrace) {
    // Catch and log any unexpected errors during execution
    print("Error during background fetch: $e");
    print(stacktrace);
  }

  BackgroundFetch.finish(taskId);
}
