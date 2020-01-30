import 'package:flutter/material.dart';

import 'task.dart';
import 'task_io.dart';
import 'task_list.dart';

/// A route for the user to enter and add tasks.
class AddTask extends StatefulWidget {
  final callback;
  Task task;

  int index;
  AddTask(this.callback);
  AddTask.edit(this.callback, this.task, this.index);

  @override
  AddTaskState createState() => AddTaskState();
}

/// The state that allows a task to be added.
class AddTaskState extends State<AddTask> {
  /// A controller for text in the title field.
  TextEditingController titleController;

  /// A controller for text in the body field.
  TextEditingController bodyController;

  /// Builds the interface for the user to enter task details.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add New Task')),
        body: Center(
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3.0))),
            elevation: 3.0,
            margin: EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // The title entry field.
                ListTile(
                  leading: Icon(Icons.title),
                  title: TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'New task'),
                  ),
                ),

                Divider(thickness: 1.0),

                // The (optional) body entry field.
                Expanded(
                  child: ListTile(
                    title: TextField(
                      controller: bodyController,
                      autofocus: false,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Add details'),
                    ),
                  ),
                ),

                // Save/Delete task button bar
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ButtonBar(
//                      alignment: MainAxisAlignment.spaceBetween,
                      alignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            // The delete button.
                            IconButton(
                              alignment: Alignment.centerRight,
                              icon: Icon(Icons.delete),
                              onPressed: deleteTask,
                            ),
                            // The save button.
                            FlatButton(
                              child: const Text('SAVE'),
                              onPressed: () => saveTask(Task(
                                  titleController.text, bodyController.text)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  /// Deletes the current task.
  void deleteTask() {
    if (isEditMode()) {
      // Remove from the task list.
      TaskListState.tasks.removeAt(widget.index);
      TaskIO.writeTasks(TaskListState.tasks);
    }

    // Dismiss.
    widget.callback();
    Navigator.pop(context);
  }

  /// Cleans up controllers.
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  /// Sets [titleController] and [bodyController] to previously specified values
  /// if the task is being edited. Otherwise, they are default (blank).
  @override
  void initState() {
    super.initState();

    if (isEditMode()) {
      // Use strings from existing task instance to set text values.
      titleController = TextEditingController(text: widget.task.title);
      bodyController = TextEditingController(text: widget.task.body);
    } else {
      titleController = TextEditingController();
      bodyController = TextEditingController();
    }
  }

  /// Checks if a task is being edited rather than added.
  bool isEditMode() => widget.task != null;

  /// Saves the task to [TaskListState.tasks] and writes to disk.
  void saveTask(task) {
    if (isEditMode()) {
      // Edit the existing task in [TaskListState.tasks].
      if (widget.task.isReminderSet)
        task.setDateTime(widget.task.date, widget.task.time);
      TaskListState.tasks[widget.index] = task;
    } else {
      // Add a new task.
      TaskListState.tasks.add(task);
    }

    TaskIO.writeTasks(TaskListState.tasks);

    // Dismiss.
    widget.callback();
    Navigator.pop(context);
  }
}
