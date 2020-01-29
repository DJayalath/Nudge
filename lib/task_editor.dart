import 'package:flutter/material.dart';

import 'package:flutter_nudge_reminders/task_list.dart';
import 'package:flutter_nudge_reminders/task_io.dart';

class TaskEditor {

  static void saveTask(task, widget, context) {
    TaskIO.writeTasks(TaskListState.tasks);
    widget.callback();
    Navigator.pop(context);
  }

  static void deleteTask(task, widget, context) {
    widget.callback();
    Navigator.pop(context);
  }

}