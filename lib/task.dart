import 'package:flutter/material.dart';

/// A generic task.
class Task {
  /// The task title.
  final _title;

  /// Additional information about the task.
  final _body;

  /// The date the task should be completed by.
  var _selectedDate;

  /// The time the task should be completed by.
  var _selectedTime;

  /// The task completion status.
  var _isComplete = false;

  /// Whether the task has a reminder set.
  var _shouldRemind = false;

  Task(this._title, this._body);

  String get body => _body;

  DateTime get date => _selectedDate;

  bool get isComplete => _isComplete;

  bool get isReminderSet => _shouldRemind;

  TimeOfDay get time => _selectedTime;

  String get title => _title;

  /// Checks if body has a non-empty string value.
  bool isBodySet() => _body != "";

  /// Removes the task reminder.
  void resetDateTime() {
    _shouldRemind = false;
    _selectedDate = null;
    _selectedTime = null;
  }

  /// Sets a reminder for the task with a [date] and [time] for completion.
  void setDateTime(date, time) {
    _shouldRemind = true;
    _selectedDate = date;
    _selectedTime = time;
  }

  /// Toggles the completion status of the task.
  void toggleComplete() => _isComplete = !_isComplete;

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
      Duration dateADiff = DateTime.now().difference(a.date);
      Duration dateBDiff = DateTime.now().difference(b.date);

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
          // [a] and [b] both are on the same date. Sort deadlock by soonest time.
          // TODO: Make this more efficient.
          TimeOfDay timeNow = TimeOfDay.now();

          // Calculate times in hours.
          double now =
              timeNow.hour.toDouble() + (timeNow.minute.toDouble() / 60);
          double timeOfAInHours =
              a.time.hour.toDouble() + (a.time.minute.toDouble() / 60);
          double timeOfBInHours =
              b.time.hour.toDouble() + (b.time.minute.toDouble() / 60);

          // Calculate time difference between now and the task times.
          double timeUntilA = (timeOfAInHours - now).abs();
          double timeUntilB = (timeOfBInHours - now).abs();

          // Calculate the difference between the tasks' upcoming times.
          double diff = timeUntilA - timeUntilB;

          // Put the soonest task on top
          if (diff > 0) {
            return -1;
          } else if (diff < 0) {
            return 1;
          } else {
            // If both tasks at exact same time, make no distinction.
            return 0;
          }
          break;
      }
    }

    // Make no distinction if both tasks have no reminder.
    return 0;
  }
}
