import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'task.dart';

class NotificationScheduler {

  /// Flutter local notifications plugin instance.
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static void init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  static deleteNotification(Task task) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(task.computeHash());
    } catch (e) {}
  }

  static scheduleNotification(Task task) async {

    var hash = task.computeHash();

    try {
      await flutterLocalNotificationsPlugin.cancel(hash);
    } catch (e) {}

    var android = AndroidNotificationDetails('channel id', 'channel NAME', 'CHANNEL DESCRIPTION');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.schedule(
        hash,
        task.title,
        '1',
        task.date,
        platform, payload: 'Item');
  }

}