import 'package:flutter/material.dart';

import 'package:flutter_nudge_reminders/task_list.dart';
import 'package:flutter_nudge_reminders/task.dart';

class DateTimeDialog extends StatefulWidget {

  final callback;
  final i;
  DateTimeDialog(this.i, this.callback);

  @override
  DateTimeDialogState createState() => new DateTimeDialogState();
}

class DateTimeDialogState extends State<DateTimeDialog> {

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select date/time'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () => _selectDate(context, this.widget.i),
          child: Text("${TaskListState.tasks[this.widget.i].selectedDate.toLocal()}".split(' ')[0]),
        ),
        SimpleDialogOption(
          onPressed: () => _selectTime(context, this.widget.i),
          child: Text("${TaskListState.tasks[this.widget.i].selectedTime.format(context)}"),
        ),
        FlatButton(
          child: const Text('SAVE'),
          onPressed: () {
            this.widget.callback();
            Navigator.pop(context);
            },
        )
      ],
    );
  }

  Future<Null> _selectDate(BuildContext context, index) async {
    Task task = TaskListState.tasks[index];
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: task.selectedDate != DateTime(2015, 8) ? task.selectedDate : DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != TaskListState.tasks[index].selectedDate)
      setState(() {
        TaskListState.tasks[index].selectedDate = picked;
      });
  }

  Future<Null> _selectTime(BuildContext context, index) async {
    Task task = TaskListState.tasks[index];
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: task.selectedTime != TimeOfDay(hour: 0, minute: 0) ? task.selectedTime : TimeOfDay.now(),
    );
    if (picked != null && picked != task.selectedTime)
      setState(() {
        task.selectedTime = picked;
      });
  }

}