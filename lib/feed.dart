import 'package:firebase_database/firebase_database.dart';

Future<void> sendFeedingCommand(
  String unitId,
  String feedingType,
  double quantity,
) async {
  // Validate feeding type;
  if (feedingType != "auto" && feedingType != "manual") {
    throw ArgumentError("Feeding type must be either 'auto' or 'manual'");
  }

  // Prepare the command payload as a map
  final Map<String, dynamic> command = {
    "type": feedingType,
    "quantity": quantity,
    "timestamp":
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // UNIX timestamp
  };
  // Get a reference to the pump command path for the specified unit
  final DatabaseReference ref = FirebaseDatabase.instance.ref("pump/$unitId");

  // Send the command to Firebase (this will trigger the pump via IoT)
  await ref.set(command);

   // Log the command for debugging purposes
  print("Feeding command sent: $command");
}
