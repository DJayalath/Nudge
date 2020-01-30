import 'package:flutter/material.dart';
import 'package:flutter_nudge_reminders/task.dart';

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

  /// Builds the dialog as a simple selection menu.
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select date/time'),
      children: <Widget>[
        // The date picker.
        SimpleDialogOption(
          onPressed: () => _selectDate(context),
          child: Text("${date.toLocal()}".split(' ')[0]),
        ),

        // The time picker.
        SimpleDialogOption(
          onPressed: () => _selectTime(context),
          child: Text("${time.format(context)}"),
        ),

        // Delete reminder button.
        FlatButton(
          child: const Text('DELETE'),
          onPressed: () {
            widget.task.resetDateTime();
            widget.callback();
            Navigator.pop(context);
          },
        ),

        // Save reminder button.
        FlatButton(
          child: const Text('SAVE'),
          onPressed: () {
            widget.task.setDateTime(date, time);
            widget.callback();
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  /// Sets the initial [date] and [time] to the existing values for the given task.
  @override
  void initState() {
    // Check that a reminder has been set first.
    if (widget.task.isReminderSet) {
      date = widget.task.date;
      time = widget.task.time;
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
    if (picked != null && picked != widget.task.date)
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
    if (picked != null && picked != widget.task.time)
      setState(() {
        time = picked;
      });
  }
}
