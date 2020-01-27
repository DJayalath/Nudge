import 'package:flutter/material.dart';

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

    return Container(
      margin: EdgeInsets.all(5.0),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: tasks.length,
          // Make cards
          itemBuilder: (context, i) {
            return Dismissible(

              key: Key(tasks[i].title),

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
                            tasks[i].title,
                            style: tasks[i].complete ? TextStyle(decoration: TextDecoration.lineThrough) : null,
                          ),
                          subtitle: (tasks[i].body != "") ? Text(tasks[i].body) : null,
                          leading: IconButton(
                            icon: Icon(tasks[i].complete ? Icons.check_box : Icons.check_box_outline_blank),
                            onPressed: () {
                              setState(() {
                                tasks[i].complete = !tasks[i].complete;
                              });
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.alarm_add),
                            onPressed: () {

                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return DateTimeDialog(i, this.callback);
                                  }
                              );
                            },
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.alarm_on),
                          title: Text(
                            tasks[i].selectedTime.format(context),
                            style: _dateTimeStyle,
                          ),
                          trailing: Text(
                            tasks[i].selectedDate.toString().split(' ')[0],
                            style: _dateTimeStyle,
                          ),
                        )
                      ],
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