import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_nudge_reminders/task.dart';
import 'package:flutter_nudge_reminders/add_task.dart';
import 'package:flutter_nudge_reminders/edit_task.dart';
import 'package:flutter_nudge_reminders/date_time_dialog.dart';

class TaskList extends StatefulWidget {

  @override
  TaskListState createState() => TaskListState();

}

class TaskListState extends State<TaskList> {

  static List<Task> tasks = [];

  /*
  Sort tasks such that:
  - Timeless tasks at top
  - Tasks coming up sooner above tasks coming up later
   */
  static int sortTasks(Task a, Task b)  {

    if (!a.shouldRemind() && b.shouldRemind()) {
      return -1;
    }
    else if (!b.shouldRemind() && a.shouldRemind()) {
      return 1;
    } else if (a.shouldRemind() && b.shouldRemind()) {

      Duration dateADiff = DateTime.now().difference(a.getDate());
      Duration dateBDiff = DateTime.now().difference(b.getDate());

      switch (dateADiff.compareTo(dateBDiff)) {
        case 1:
          return -1;
          break;
        case -1:
          return 1;
          break;
        // Handle deadlock between dates with time (expensive but rare)
        case 0:
          TimeOfDay nowTime = TimeOfDay.now();
          double now = nowTime.hour.toDouble() + (nowTime.minute.toDouble() / 60);
          double aTime = a.getTime().hour.toDouble() + (a.getTime().minute.toDouble() / 60);
          double bTime = b.getTime().hour.toDouble() + (b.getTime().minute.toDouble() / 60);
          double timeADiff = (aTime - now).abs();
          double timeBDiff = (bTime - now).abs();
          double diff = timeADiff - timeBDiff;
          if (diff > 0) {
            return -1;
          } else if (diff < 0) {
            return 1;
          } else {
            return 0;
          }
          break;
      }

    }

    return 0;

  }

  final _dateTimeStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w300,
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
          title: Text('Nudge Tasks')
      ),

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

  // Pushes add task route
  void _pushAddTaskRoute() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTask(this.callback)),
    );
  }

  void _editTaskRoute(task, index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTask(this.callback, task, index)),
    );
  }

  Widget _buildContent() {

    bool notNull(Object o) => o != null;
    tasks.sort(sortTasks);

    return Container(
      margin: EdgeInsets.all(5.0),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: tasks.length,
          // Make cards
          itemBuilder: (context, i) {
            return Dismissible(

              key: Key(tasks[i].getTitle()),

              background: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Icon(
                          Icons.delete
                      ),
                    ),
                  )
              ),

              direction: DismissDirection.startToEnd,

              onDismissed: (direction){

                // Remove from tasks
                setState(() {
                  tasks.removeAt(i);
                });

                // Show a snackbar. This snackbar could also contain "Undo" actions.
                Scaffold
                    .of(context)
                    .showSnackBar(
                    SnackBar(
                      content: Text("Task dismissed"),
                      duration: Duration(seconds: 2),
                    )
                );
              },

              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: InkWell(

                  onTap: () => _editTaskRoute(tasks[i], i),

                  child: Container(
                    //                decoration: ,
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            tasks[i].getTitle(),
                            style: tasks[i].isComplete() ? TextStyle(decoration: TextDecoration.lineThrough) : null,
                          ),
                          subtitle: tasks[i].isBodySet() ? Text(tasks[i].getBody()) : null,
                          leading: IconButton(
                            icon: Icon(tasks[i].isComplete() ? Icons.check_box : Icons.check_box_outline_blank),
                            onPressed: () {
                              setState(() {
                                tasks[i].toggleComplete();
                              });
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(tasks[i].shouldRemind() ? Icons.alarm_on : Icons.alarm_add),
                            onPressed: () {

                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return DateTimeDialog(tasks[i], this.callback);
                                  }
                              );
                            },
                          ),
                        ),
                        if (tasks[i].shouldRemind())
                          Divider(),
                        if (tasks[i].shouldRemind())
                          ListTile(
                            title: Text(
                              tasks[i].getTime().format(context),
                              style: _dateTimeStyle,
                            ),
                            trailing: Text(
                              tasks[i].getDate().toString().split(' ')[0],
                              style: _dateTimeStyle,
                            ),
                          ),
                      ].where(notNull).toList(),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );

  }

  void callback() {
    setState(() {});
  }

}