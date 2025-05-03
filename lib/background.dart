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

  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  try {
    await Firebase.initializeApp();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in.");
      BackgroundFetch.finish(taskId);
      return;
    }

    DataSnapshot unitsSnapshot =
        await FirebaseDatabase.instance
            .ref('units')
            .orderByChild('owner')
            .equalTo(user.uid)
            .get();

    if (!unitsSnapshot.exists) {
      print("User does not have any units.");
      BackgroundFetch.finish(taskId);
      return;
    }

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
      final dataRef = FirebaseDatabase.instance.ref("data/${unit.id}");
      final dataSnapshot = await dataRef.orderByKey().limitToLast(1).get();
      if (!dataSnapshot.exists) continue;
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

      if (quantity > 0) {
        await showFeedingNotification(unit, quantity);
      }
    }
  } catch (e, stacktrace) {
    print("Error during background fetch: $e");
    print(stacktrace);
  }

  BackgroundFetch.finish(taskId);
}
