import 'package:flutter/material.dart';

import 'package:flutter_nudge_reminders/add_task.dart';
import 'package:flutter_nudge_reminders/task_list.dart';
import 'package:flutter_nudge_reminders/task.dart';
import 'package:flutter_nudge_reminders/task_io.dart';

class EditTask extends AddTask {

  final Task _task;
  final _index;
  EditTask(callback, this._task, this._index) : super(callback);

  @override
  EditTaskState createState() => EditTaskState(_task, _index);
}

class EditTaskState extends AddTaskState {

  final index;
  final Task task;

  EditTaskState(this.task, this.index) {
    titleController = TextEditingController(text: task.getTitle());
    bodyController = TextEditingController(text: task.getBody());
  }

  @override
  void saveTask(task) {
    if (this.task.shouldRemind())
      task.setDateTime(this.task.getDate(), this.task.getTime());
    TaskListState.tasks[index] = task;
    TaskIO.writeTasks(TaskListState.tasks);
    this.widget.callback();
    Navigator.pop(context);
  }

  @override
  void deleteTask() {
    TaskListState.tasks.removeAt(index);
    TaskIO.writeTasks(TaskListState.tasks);
    super.deleteTask();
  }

}