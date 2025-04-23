import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

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

      // Call algorithm on it
      // bool shouldFeed = await algorithm(latestEntry);
      // if (shouldFeed) {
      //   await showFeedingNotification(30);
      // }
    }
  } catch (e, stacktrace) {
    print("Error during background fetch: $e");
    print(stacktrace);
  }

  BackgroundFetch.finish(taskId);
}
