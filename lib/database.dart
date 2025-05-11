import 'package:firebase_database/firebase_database.dart';

Future<Map<String, dynamic>> getLatestEnvironmentalData() async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('data/unit_1');
  DataSnapshot snapshot = await ref.orderByKey().limitToLast(1).get();
  if (snapshot.exists) {
    Map<String, dynamic> data = Map<String, dynamic>.from(
      snapshot.value as Map,
    );
    return data.values.first; // Return the latest entry
  }
  return {};
}

Future<Map<String, dynamic>> getLastFeedingData() async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('feed/unit_1');
  // Get the latest (most recent) feeding record using limitToLast(1)
  DataSnapshot snapshot = await ref.orderByKey().limitToLast(1).get();
  // If feeding data exists, convert it into a Map and return the first (latest) value
  if (snapshot.exists) {
    Map<String, dynamic> data = Map<String, dynamic>.from(
      snapshot.value as Map,
    );
    return data.values.first; // Return the latest feeding record
  }
  return {}; // If no feeding data found, return an empty map
}
