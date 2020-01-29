import 'package:flutter/material.dart';
import 'package:flutter_nudge_reminders/add_task.dart';
import 'package:flutter_nudge_reminders/date_time_dialog.dart';
import 'package:flutter_nudge_reminders/edit_task.dart';
import 'package:flutter_nudge_reminders/task.dart';
import 'package:flutter_nudge_reminders/task_io.dart';

/// The list of tasks displayed in the home page of the app.
class TaskList extends StatefulWidget {
  @override
  TaskListState createState() => TaskListState();
}

/// The state that shows the list of tasks.
class TaskListState extends State<TaskList> {
  /// The list of current tasks.
  static List<Task> tasks = [];

  /// A lighter text style for dates and times.
  final _dateTimeStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w300,
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
    TaskIO.readTasks().then((List<Task> taskList) {
      setState(() {
        tasks = taskList;
      });
    });
  }

  /// Builds the list of tasks to show.
  Widget _buildContent() {
    /// Checks if an object exists.
    bool notNull(Object o) => o ?? false;

    // Sort the tasks before building the task list widget.
    tasks.sort(sortTasks);

    return Container(
      margin: EdgeInsets.all(5.0),

      // Build a list of cards containing each task.
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: tasks.length,

          // Create a dismissible card for each task.
          itemBuilder: (context, i) {
            return Dismissible(
              key: Key(tasks[i].title),

              // Create a "leave behind" indicator to show this will delete the task.
              background: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Icon(Icons.delete),
                    ),
                  )),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                // Remove from tasks
                setState(() {
                  tasks.removeAt(i);
                });

                // Indicate that a task has been dismissed to the user.
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Task dismissed"),
                  duration: Duration(seconds: 2),
                ));
              },
              child: Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),

                // This allows the card to be tapped to edit the task.
                child: InkWell(
                  onTap: () => _editTaskRoute(tasks[i], i),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: <Widget>[
                        // The title and body are shown in the main ListTile.
                        ListTile(
                          title: Text(
                            tasks[i].title,
                            style: tasks[i].isComplete
                                ? TextStyle(
                                    decoration: TextDecoration.lineThrough)
                                : null,
                          ),
                          subtitle:
                              tasks[i].isBodySet() ? Text(tasks[i].body) : null,
                          leading: IconButton(
                            icon: Icon(tasks[i].isComplete
                                ? Icons.check_box
                                : Icons.check_box_outline_blank),
                            onPressed: () {
                              setState(() {
                                tasks[i].toggleComplete();
                              });
                            },
                          ),

                          // Allow the option to add/edit a reminder.
                          trailing: IconButton(
                            icon: Icon(tasks[i].isReminderSet
                                ? Icons.alarm_on
                                : Icons.alarm_add),
                            onPressed: () {
                              showDialog(
                                  context: context,

                                  // Push a dialog to set a date and time for the reminder.
                                  builder: (_) {
                                    return DateTimeDialog(
                                        tasks[i], this.callback);
                                  });
                            },
                          ),
                        ),

                        // Separate main title/body from (optional) reminder information.
                        if (tasks[i].isReminderSet)
                          Divider(),

                        if (tasks[i].isReminderSet)
                          // Show the user the date and time of the set reminder.
                          ListTile(
                            title: Text(
                              tasks[i].time.format(context),
                              style: _dateTimeStyle,
                            ),
                            trailing: Text(
                              tasks[i].date.toString().split(' ')[0],
                              style: _dateTimeStyle,
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

  /// Pushes the route [EditTask] that allows tasks to be edited.
  void _editTaskRoute(task, index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditTask(this.callback, task, index)),
    );
  }

  /// Pushes the route [AddTask] that allows tasks to be added.
  void _pushAddTaskRoute() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTask(this.callback)),
    );
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
