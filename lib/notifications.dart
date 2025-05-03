import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'feed.dart';
import 'unit.dart';

const notificationChannelId = 'bee_feeder_channel';

const notificationId = 888;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> onNotificationTap(NotificationResponse response) async {
  print("Notification tapped: ${response.payload}");

  await Firebase.initializeApp();

  if (response.payload != null) {
    List<String> payloadParts = response.payload!.split(',');
    if (payloadParts.length == 2) {
      String id = payloadParts[0];
      double quantity = double.tryParse(payloadParts[1]) ?? 0.0;
      if (quantity > 0) {
        sendFeedingCommand(id, 'auto', quantity);
      }
    }
  }
}

void initializeNotifications() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

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

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'feeding_channel',
      'Bee Feeding Notifications',
      channelDescription: 'Notifications for bee feeding alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

Future<void> showFeedingNotification(Unit unit, double quantity) async {
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    'Bee Feeding Alert: ${unit.nickname}',
    'It is time to feed the bees with $quantity ml of sugar syrup. Tap to start the automation',
    platformChannelSpecifics,
    payload: '${unit.id},$quantity',
  );
}
