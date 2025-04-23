import 'package:firebase_database/firebase_database.dart';

Future<void> sendFeedingCommand(String feedingType, double quantity) async {
  if (feedingType != "auto" && feedingType != "manual") {
    throw ArgumentError("Feeding type must be either 'auto' or 'manual'");
  }

  final Map<String, dynamic> command = {
    "type": feedingType,
    "quantity": quantity,
    "timestamp":
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // UNIX timestamp
  };

  final DatabaseReference ref = FirebaseDatabase.instance.ref("pump/unit_1");

  await ref.set(command);

  print("Feeding command sent: $command");
}
