import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'landing.dart';
import 'notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeNotifications();
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: landing());
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        // <-- Event handler
        // This is the fetch-event callback.
        print("[BackgroundFetch] Event received $taskId");
        // IMPORTANT:  You must signal completion of your task or the OS can punish your app
        // for taking too long in the background.
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        // <-- Task timeout handler.
        // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
        print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
        BackgroundFetch.finish(taskId);
      },
    );
    print('[BackgroundFetch] configure success: $status');
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }
}

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

    final userRef = FirebaseDatabase.instance.ref("users/${user.uid}");
    final userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      print("User data does not exist.");
      BackgroundFetch.finish(taskId);
      return;
    }

    final userData = userSnapshot.value as Map<dynamic, dynamic>;
    final units = List<String>.from(userData["units"] ?? []);

    for (String unitId in units) {
      final dataRef = FirebaseDatabase.instance.ref("data/$unitId");
      final latestSnapshot = await dataRef.orderByKey().limitToLast(1).get();

      if (!latestSnapshot.exists) continue;

      // Get the last data entry
      final latestEntry = (latestSnapshot.value as Map).values.first;

      print(latestEntry);

      // Call algorithm on it
      // bool shouldFeed = await algorithm(latestEntry);
      // if (shouldFeed) {
      await showFeedingNotification(30);
      // }
    }
    await showFeedingNotification(30);
  } catch (e, stacktrace) {
    print("Error during background fetch: $e");
    print(stacktrace);
  }

  BackgroundFetch.finish(taskId);
}
