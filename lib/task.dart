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
}
