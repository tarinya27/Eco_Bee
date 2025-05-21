import 'package:firebase_database/firebase_database.dart';

//Fetches the latest environmental data entry for unit_1 from Firebase Realtime Database.
Future<Map<String, dynamic>> getLatestEnvironmentalData() async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('data/unit_1');
  // Query to get the last entry (latest) by ordering keys and limiting to 1
  DataSnapshot snapshot = await ref.orderByKey().limitToLast(1).get();
    // Check if any data exists
  if (snapshot.exists) {
    Map<String, dynamic> data = Map<String, dynamic>.from(
      snapshot.value as Map,
    );
    return data.values.first; // Return the latest entry
  }
  return {};
}

Future<Map<String, dynamic>> getLastFeedingData() async {
  // Reference to the 'feed/unit_1' node in the database
  DatabaseReference ref = FirebaseDatabase.instance.ref('feed/unit_1');
 // Query to get the latest feeding record by ordering keys and limiting to 1
  DataSnapshot snapshot = await ref.orderByKey().limitToLast(1).get();
 // Check if any feeding data exists
  if (snapshot.exists) {
    Map<String, dynamic> data = Map<String, dynamic>.from(
      snapshot.value as Map,
    );
    // Return the first (latest) feeding record from the map's values
    return data.values.first;
  }
  // If no feeding data exists, return an empty map
  return {};
}
