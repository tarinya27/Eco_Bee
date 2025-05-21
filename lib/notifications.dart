import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'feed.dart';
import 'unit.dart';

const notificationChannelId = 'bee_feeder_channel';

const notificationId = 888;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Callback triggered when the user taps a notification.
/// It parses the payload and sends an automated feeding command if valid.

@pragma('vm:entry-point')
Future<void> onNotificationTap(NotificationResponse response) async {
  print("Notification tapped: ${response.payload}");

  // Initialize Firebase in case it's needed (especially in background)
  await Firebase.initializeApp();
  if (response.payload != null) {
    List<String> payloadParts = response.payload!.split(',');
    if (payloadParts.length == 2) {
      String id = payloadParts[0];
      double quantity = double.tryParse(payloadParts[1]) ?? 0.0;

      // Only send feeding command if quantity is valid
      if (quantity > 0) {
        sendFeedingCommand(id, 'auto', quantity);
      }
    }
  }
}

void initializeNotifications() {

  // Request permission for showing notifications (Android 13+)
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();
 
  // Android-specific initialization settings (e.g., app icon)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onNotificationTap,
    onDidReceiveBackgroundNotificationResponse: onNotificationTap,
  );
}

// Android-specific configuration for how notifications should appear
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'feeding_channel',
      'Bee Feeding Notifications',
      channelDescription: 'Notifications for bee feeding alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

/// Displays a notification reminding the user to feed the bees.
/// When tapped, the notification triggers automated feeding.

Future<void> showFeedingNotification(Unit unit, double quantity) async {
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
 
  // Show the notification with dynamic content (nickname and quantity)
  await flutterLocalNotificationsPlugin.show(
    notificationId,
    'Bee Feeding Alert: ${unit.nickname}',
    'It is time to feed the bees with $quantity ml of sugar syrup. Tap to start the automation',
    platformChannelSpecifics,
    payload: '${unit.id},$quantity', // Sent with the notification for use on tap
  );
}
