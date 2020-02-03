import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'task.dart';

/// A utility class for notification scheduling.
class NotificationScheduler {

  /// A multiplier to generate unique early reminder notification IDs
  /// that can still be attached to a task ID by dividing.
  ///
  /// WARNING: This limits the max. number of tasks in the worst case
  /// (where all tasks have early reminders) to [EARLY_REMINDER_UNIQUE_CONSTANT].
  static const int EARLY_REMINDER_UNIQUE_CONSTANT = 1000;

  /// Flutter local notifications plugin instance.
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// Initialises [flutterLocalNotificationsPlugin] with platform settings and
  /// an on notification selection function - [selectionFunction].
  static void init([selectionFunction]) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: selectionFunction);
  }

  /// Attempts to cancel notifications scheduled for [task].
  ///
  /// This includes attempting to cancel any early reminder notifications
  /// that may have been set for [task].
  static deleteNotification(Task task) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(task.id);
      await flutterLocalNotificationsPlugin.cancel(task.id * EARLY_REMINDER_UNIQUE_CONSTANT);
    } catch (e) {}
  }

  /// Attempts to schedule notifications for [task] based on [task.date] and
  /// (if necessary), [task.earlyReminder].
  static scheduleNotification(Task task) async {

    // Attempt to delete existing notifications for this task in case it is being edited.
    deleteNotification(task);

    // Set and retrieve notification details for scheduling.
    var android = AndroidNotificationDetails('channel id', 'channel NAME', 'CHANNEL DESCRIPTION');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);

    var message = 'Due now';

    // Schedule main notification.
    await flutterLocalNotificationsPlugin.schedule(
        task.id,
        task.title,
        message,
        task.date,
        platform,
        payload: "${task.id}",
    );

    // Add another, earlier notification if needed.
    if (task.isEarlyReminderSet) {

      var durationInMinutes = task.earlyReminder.inMinutes;
      if (durationInMinutes > 45) {
        message = 'In ${durationInMinutes ~/ 60} hours';
      } else {
        message = 'In $durationInMinutes minutes';
      }

      await flutterLocalNotificationsPlugin.schedule(
          task.id * EARLY_REMINDER_UNIQUE_CONSTANT,
          task.title,
          message,
          task.date.subtract(task.earlyReminder),
          platform,
          payload: "${task.id}",
      );
    }
  }

}