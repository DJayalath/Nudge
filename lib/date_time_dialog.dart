import 'package:flutter/material.dart';

import 'task.dart';
import 'task_list.dart';
import 'task_io.dart';

/// A dialog to set date and time of a task.
class DateTimeDialog extends StatefulWidget {
  final callback;
  final Task task;
  DateTimeDialog(this.task, this.callback);

  @override
  DateTimeDialogState createState() => new DateTimeDialogState();
}

/// A state to control displaying the dialog.
class DateTimeDialogState extends State<DateTimeDialog> {
  /// The date of the task.
  var date = DateTime.now();

  /// The time of the task.
  var time = TimeOfDay.now();

  /// A style for selector boxes.
  final _selectorDecoration = BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  );

  /// A style for selector text.
  final _selectorStyle = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
  );

  /// Builds the dialog as a simple selection menu.
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3.0))),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.calendar_today),
          onTap: () => _selectDate(context),
          title: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: _selectorDecoration,
            child: Text(
              "${date.toLocal()}".split(' ')[0],
              style: _selectorStyle,
            ),
          ),
        ),

        ListTile(
          leading: Icon(Icons.access_time),
          onTap: () => _selectTime(context),
          title: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: _selectorDecoration,
            child: Text(
              "${time.format(context)}",
              style: _selectorStyle,
            ),
          ),
        ),

        // TODO: Add to Task class and persistent across disk writes.
        SwitchListTile(
          secondary: Icon(Icons.alarm),
          dense: false,
          title: Text("Early reminder"),
          value: false,
          onChanged: (bool value) {

          },
          isThreeLine: true,
          subtitle: Container(
              child: Text("1 hour"),
          ),
        ),

        ButtonBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                widget.task.resetDateTime();
                TaskIO.writeTasks(TaskListState.tasks);
                widget.callback();
                Navigator.pop(context);
              },
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    widget.callback();
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: const Text('SAVE'),
                  onPressed: () {
                    // Combine date and time into a single DateTime instance.
                    widget.task.setDateTime(
                        DateTime(date.year, date.month, date.day, time.hour, time.minute),
                    );
                    TaskIO.writeTasks(TaskListState.tasks);
                    widget.callback();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
        // Delete reminder button.
      ],
    );
  }

  /// Sets the initial [date] and [time] to the existing values for the given task.
  @override
  void initState() {
    // Check that a reminder has been set first.
    if (widget.task.isReminderSet) {
      date = DateTime(widget.task.date.year, widget.task.date.month, widget.task.date.day);
      time = TimeOfDay(hour: widget.task.date.hour, minute: widget.task.date.minute);
    }

    super.initState();
  }

  /// Provides an interface to select a date.
  void _selectDate(BuildContext context) async {
    // Show the date picker.
    final DateTime picked = await showDatePicker(
      context: context,

      // Set initial date to that of task if already set, otherwise now.
      initialDate: date,

      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    // Set new date if selected and different.
    if (picked != null)
      setState(() {
        date = picked;
      });
  }

  /// Provides an interface to select a time.
  void _selectTime(BuildContext context) async {
    // Show the time picker.
    final TimeOfDay picked = await showTimePicker(
      context: context,

      // Set initial time to that of task if already set. otherwise now.
      initialTime: time,
    );

    // Set new time if selected and different.
    if (picked != null)
      setState(() {
        time = picked;
      });
  }
}
