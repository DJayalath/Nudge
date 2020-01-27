import 'package:flutter/material.dart';

class Task {

  final title;
  final body;
  var complete = false;
  var selectedDate = DateTime(2015, 8);
  var selectedTime = TimeOfDay(hour: 0, minute: 0);

  Task(this.title, this.body);
}