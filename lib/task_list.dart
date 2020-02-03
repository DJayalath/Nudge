import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_task.dart';
import 'date_time_dialog.dart';
import 'task_utilities/task_manager.dart';

/// The list of tasks displayed in the home page of the app.
class TaskList extends StatefulWidget {
  @override
  TaskListState createState() => TaskListState();
}

/// The state that shows the list of tasks.
class TaskListState extends State<TaskList> {
  /// The task manager.
  TaskManager taskManager = TaskManager();

  /// A lighter text style for dates and times.
  final _dateTimeStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w300,
  );

  /// A style for reminder boxes.
  final _reminderDecoration = BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  );

  /// Shows the list of tasks.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nudge Tasks')),

      // Display list of cards of tasks
      body: _buildContent(),

      // The 'add new task' button
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddTaskRoute,
        tooltip: 'New task',
        child: Icon(Icons.note_add),
      ),
    );
  }

  /// Invokes rebuild of app from another route.
  ///
  /// Used when task list is updated when a task is added or edited.
  void callback() {
    setState(() {});
  }

  /// Reads the task list from disk to display.
  @override
  void initState() {
    super.initState();

    // Read tasks from disk by initialising taskManager.
    taskManager.init(callback);
  }

  /// Builds the list of tasks to show.
  Widget _buildContent() {
    /// Checks if an object exists.
    bool notNull(Object o) => o != null;

    // Sort the tasks before building the task list widget.
    taskManager.sort();

    return Container(
      margin: EdgeInsets.all(5.0),

      // Build a list of cards containing each task.
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: taskManager.length,

          // Create a dismissible card for each task.
          itemBuilder: (context, i) {
            return Dismissible(
              key: Key(taskManager.getTask(i).title),
//              movementDuration: Duration(milliseconds: 50),
              dismissThresholds: {
                DismissDirection.startToEnd: 0.5,
              },
              // Create a "leave behind" indicator to show this will delete the task.
              background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(3.0)),
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 5.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Icon(Icons.delete),
                    ),
                  )),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                // Remove from tasks
                setState(() {
                  taskManager.removeTaskAt(i);
                });

                // Indicate that a task has been dismissed to the user.
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Task dismissed"),
                  duration: Duration(seconds: 2),
                ));
              },
              child: Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3.0))),
                margin:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),

                // This allows the card to be tapped to edit the task.
                child: InkWell(
                  onTap: () => _editTaskRoute(taskManager.getTask(i), i),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    child: Column(
                      children: <Widget>[
                        // The title and body are shown in the main ListTile.
                        ListTile(
                          title: Text(
                            taskManager.getTask(i).title,
                            style: taskManager.getTask(i).isComplete
                                ? TextStyle(
                                    decoration: TextDecoration.lineThrough)
                                : null,
                          ),
                          subtitle: taskManager.getTask(i).isBodySet()
                              ? Text(taskManager.getTask(i).body)
                              : null,
                          leading: IconButton(
                            icon: Icon(
                                taskManager.getTask(i).isComplete
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: taskManager.getTask(i).isComplete
                                    ? Colors.green
                                    : null),
                            onPressed: () {
                              // Toggle completion state.
                              setState(() {
                                taskManager.getTask(i).toggleComplete();
                              });
                            },
                          ),

                          // Allow the option to add/edit a reminder.
                          trailing: IconButton(
                            icon: Icon(
                              taskManager.getTask(i).isReminderSet
                                  ? Icons.alarm_on
                                  : Icons.alarm_add,
                              color: taskManager.getTask(i).isReminderSet
                                  ? Colors.green
                                  : null,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,

                                  // Push a dialog to set a date and time for the reminder.
                                  builder: (_) {
                                    return DateTimeDialog(
                                        taskManager.getTask(i), this.callback);
                                  });
                            },
                          ),
                        ),

                        // Separate main title/body from (optional) reminder information.
                        if (taskManager.getTask(i).isReminderSet)
                          Divider(
                            indent: 15.0,
                            endIndent: 15.0,
                            thickness: 1.0,
                            color: Colors.grey[300],
                          ),

                        if (taskManager.getTask(i).isReminderSet)
                          // Show the user the date and time of the set reminder.
                          ListTile(
                            dense: true,
                            trailing: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: _reminderDecoration,
                              child: Text(
                                DateFormat("HH:mm")
                                    .format(taskManager.getTask(i).date),
                                style: _dateTimeStyle,
                              ),
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: _reminderDecoration,
                              child: Text(
                                DateFormat("dd-MM-yyyy")
                                    .format(taskManager.getTask(i).date),
                                style: _dateTimeStyle,
                              ),
                            ),
                          ),
                      ].where(notNull).toList(),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  /// Pushes the route [AddTask.edit] that allows tasks to be edited.
  void _editTaskRoute(task, index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddTask.edit(this.callback, task, index)),
    );
  }

  /// Pushes the route [AddTask] that allows tasks to be added.
  void _pushAddTaskRoute() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTask(this.callback)),
    );
  }
}
