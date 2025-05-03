import 'package:firebase_database/firebase_database.dart';

Future<void> sendFeedingCommand(
  String unitId,
  String feedingType,
  double quantity,
) async {
  if (feedingType != "auto" && feedingType != "manual") {
    throw ArgumentError("Feeding type must be either 'auto' or 'manual'");
  }

  final Map<String, dynamic> command = {
    "type": feedingType,
    "quantity": quantity,
    "timestamp":
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // UNIX timestamp
  };

  final DatabaseReference ref = FirebaseDatabase.instance.ref("pump/$unitId");

  await ref.set(command);

  print("Feeding command sent: $command");
}
