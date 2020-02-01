import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'task.dart';

class NotificationScheduler {

  /// Flutter local notifications plugin instance.
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static void init(selectionFunction) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: selectionFunction);
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

    var message = 'Due now';
    var time = task.date;
    if (task.isEarlyReminderSet) {
      time = time.subtract(task.earlyReminder);
      var durationInMinutes = task.earlyReminder.inMinutes;
      message = 'In $durationInMinutes ${(durationInMinutes > 45) ? "hours" : "minutes"}';
    }

    var android = AndroidNotificationDetails('channel id', 'channel NAME', 'CHANNEL DESCRIPTION');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.schedule(
        hash,
        task.title,
        message,
        time,
        platform, payload: task.title);
  }

}