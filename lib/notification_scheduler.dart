import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'task.dart';

class NotificationScheduler {

  static const int EARLY_REMINDER_UNIQUE_CONSTANT = 1000;

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
      await flutterLocalNotificationsPlugin.cancel(task.id);
      await flutterLocalNotificationsPlugin.cancel(task.id * EARLY_REMINDER_UNIQUE_CONSTANT);
    } catch (e) {}
  }

  static scheduleNotification(Task task) async {

    deleteNotification(task);

    var message = 'Due now';

    var android = AndroidNotificationDetails('channel id', 'channel NAME', 'CHANNEL DESCRIPTION');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);

    // Schedule main notification.
    await flutterLocalNotificationsPlugin.schedule(
        task.id,
        task.title,
        message,
        task.date,
        platform, payload: task.title
    );

    // Add another, earlier notification if needed.
    if (task.isEarlyReminderSet) {

      var time = task.date;
      time = time.subtract(task.earlyReminder);
      var durationInMinutes = task.earlyReminder.inMinutes;
      message = 'In $durationInMinutes ${(durationInMinutes > 45) ? "hours" : "minutes"}';

      await flutterLocalNotificationsPlugin.schedule(
          task.id * EARLY_REMINDER_UNIQUE_CONSTANT, // TODO: This limits max. unique tasks to 1000 if all have early reminders.
          task.title,
          message,
          time,
          platform, payload: task.title
      );
    }
  }

}