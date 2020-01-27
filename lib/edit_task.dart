import 'package:flutter/material.dart';

import 'package:flutter_nudge_reminders/add_task.dart';
import 'package:flutter_nudge_reminders/task_list.dart';
import 'package:flutter_nudge_reminders/task.dart';

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
    this.widget.callback();
    Navigator.pop(context);
  }

  @override
  void deleteTask() {
    TaskListState.tasks.removeAt(index);
    super.deleteTask();
  }

}