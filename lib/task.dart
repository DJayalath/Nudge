import 'package:flutter/material.dart';

class Task {

  final _title;
  final _body;
  var _complete = false;
  var _selectedDate;
  var _selectedTime;
  var _remind = false;

  Task(this._title, this._body);

  String getTitle() {
    return _title;
  }

  String getBody() {
    return _body;
  }

  bool isBodySet() {
    return _body != "";
  }

  void resetDateTime() {
    _remind = false;
    _selectedDate = null;
    _selectedTime = null;
  }

  void setDateTime(date, time) {
    _remind = true;
    _selectedDate = date;
    _selectedTime = time;
  }

  DateTime getDate() {
    return _selectedDate;
  }

  TimeOfDay getTime() {
    return _selectedTime;
  }

  bool shouldRemind() {
    return _remind;
  }

  bool isComplete() {
    return _complete;
  }

  void toggleComplete() {
    _complete = !_complete;
  }
}