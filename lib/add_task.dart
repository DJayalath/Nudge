import 'package:flutter/material.dart';

import 'package:flutter_nudge_reminders/task_list.dart';
import 'package:flutter_nudge_reminders/task.dart';
import 'package:flutter_nudge_reminders/task_io.dart';

class AddTask extends StatefulWidget {

  final callback;
  AddTask(this.callback);

  @override
  AddTaskState createState() => AddTaskState();

}

class AddTaskState extends State<AddTask> {

  var titleController = TextEditingController();
  var bodyController = TextEditingController();

  void saveTask(task) {
    TaskListState.tasks.add(task);
    TaskIO.writeTasks(TaskListState.tasks);
    this.widget.callback();
    Navigator.pop(context);
  }

  void deleteTask() {
    this.widget.callback();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        appBar: AppBar(
            title: Text('Add New Task')
        ),

        body: Center(

          child: Card(
            margin: EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[

                // Title entry
                ListTile(
                  leading: Icon(Icons.title),
                  title: TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter title'
                    ),
                  ),
                ),

//                // Checkbox to remind X minutes early
//                ListTile(
//                  leading: Icon(Icons.check_box_outline_blank),
//                  title: Text("Remind me 10 minutes early?"),
//                  onTap: null,
//                ),

                // Optional body entry
                Expanded(
                  child:
                  ListTile(
                    title: TextField(
                      controller: bodyController,
                      autofocus: false,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter optional details'
                      ),
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
//                        IconButton(
//                          alignment: Alignment.centerLeft,
//                          icon: Icon(Icons.alarm_add),
//                          onPressed: null,
//                        ),
                        Row(
                          children: <Widget>[
                            IconButton(
                              alignment: Alignment.centerRight,
                              icon: Icon(Icons.delete),
                              onPressed: deleteTask,
                            ),
                            FlatButton(
                              child: const Text('SAVE'),
                              onPressed: () => saveTask(
                                  Task(titleController.text, bodyController.text)
                              ),
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

        )
    );

  }

}