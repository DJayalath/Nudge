import 'dart:math';

import 'notification_scheduler.dart';

/// A generic task.
class Task {
  /// The task title.
  final _title;

  /// Additional information about the task.
  final _body;

  /// The date the task should be completed by.
  var _selectedDate;

  /// The task completion status.
  var _isComplete = false;

  /// Whether the task has a reminder set.
  var _shouldRemind = false;

  Task(this._title, this._body);

  String get body => _body;

  DateTime get date => _selectedDate;

  bool get isComplete => _isComplete;

  bool get isReminderSet => _shouldRemind;

  String get title => _title;

  /// Checks if body has a non-empty string value.
  bool isBodySet() => _body != "";

  /// Removes the task reminder.
  void resetDateTime() {
    _shouldRemind = false;
    _selectedDate = null;

    NotificationScheduler.deleteNotification(this);
  }

  /// Sets a reminder for the task with a [date] for completion.
  void setDateTime(date) {
    _shouldRemind = true;
    _selectedDate = date;

    NotificationScheduler.scheduleNotification(this);
  }

  /// Toggles the completion status of the task.
  void toggleComplete() => _isComplete = !_isComplete;

  static const int p = 53;
  static int m = pow(10, 9) + 9;

  /// Computes polynomial rolling hash function (p, m)
  int computeHash() {

    var hashVal = 0;
    var i = 0;

    for (int s in title.codeUnits) {
      hashVal += s * pow(p, i);
      i++;
    }

    return hashVal % m;
  }

  /// Sorts tasks by acting as comparator function.
  ///
  /// Follows the rule that timeless tasks should be shown on top of ones with reminders.
  /// The assumption being that timeless tasks likely need to be completed in the very
  /// immediate future. Other tasks are then shown with the ones ending soonest on top.
  /// TODO: Allow users to drag and sort tasks into their own custom order.
  /// TODO: Order should then be saved on disk and persistent across restarts.
  static int sortTasks(Task a, Task b) {
    if (!a.isReminderSet && b.isReminderSet) {
      // [a] has no reminder so show on top.
      return -1;
    } else if (!b.isReminderSet && a.isReminderSet) {
      // [b] has no reminder so show on top.
      return 1;
    } else if (a.isReminderSet && b.isReminderSet) {
      // Both [a] and [b] have reminders. Sort deadlock by which is soonest.
      // Calculate difference between time now and set date.
      final dateADiff = DateTime.now().difference(a.date);
      final dateBDiff = DateTime.now().difference(b.date);

      // Use the difference to decide which task is soonest.
      switch (dateADiff.compareTo(dateBDiff)) {
        case 1:
          // [b] is sooner so show [b] on top.
          return -1;
          break;
        case -1:
          // [a] is sooner so show [a] on top.
          return 1;
          break;
        case 0:
          return 0;
          break;
      }
    }

    // Make no distinction if both tasks have no reminder.
    return 0;
  }
}
