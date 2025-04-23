import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'feed.dart';

const notificationChannelId = 'bee_feeder_channel';

const notificationId = 888;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> onNotificationTap(NotificationResponse response) async {
  print("Notification tapped: ${response.payload}");
  if (response.payload != null) {
    if (response.payload == 'manual') {
      sendFeedingCommand('manual', 30);
    } else {
      double quantity = double.tryParse(response.payload!) ?? 0;
      if (quantity > 0) {
        sendFeedingCommand('auto', quantity);
      } else {
        print("Invalid quantity received: ${response.payload}");
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

Future<void> showFeedingNotification(double quantity) async {
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    'Bee Feeding Alert',
    'It is time to feed the bees with $quantity ml of sugar syrup.',
    platformChannelSpecifics,
    payload: quantity.toString(),
  );
}

Future<bool> checkAndNotify() async {
  await showFeedingNotification(30);
  return true;
}
