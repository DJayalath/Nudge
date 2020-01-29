import 'package:flutter/material.dart';

import 'package:flutter_nudge_reminders/task.dart';

class DateTimeDialog extends StatefulWidget {

  final callback;
  final Task task;
  DateTimeDialog(this.task, this.callback);

  @override
  DateTimeDialogState createState() => new DateTimeDialogState();
}

class DateTimeDialogState extends State<DateTimeDialog> {

  var date = DateTime.now();
  var time = TimeOfDay.now();

  @override
  void initState() {

    if (this.widget.task.isReminderSet) {
      date = this.widget.task.date;
      time = this.widget.task.time;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return SimpleDialog(
      title: const Text('Select date/time'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () => _selectDate(context),
          child: Text("${date.toLocal()}".split(' ')[0]),
        ),
        SimpleDialogOption(
          onPressed: () => _selectTime(context),
          child: Text("${time.format(context)}"),
        ),
        FlatButton(
          child: const Text('DELETE'),
          onPressed: () {
            this.widget.task.resetDateTime();
            this.widget.callback();
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: const Text('SAVE'),
          onPressed: () {
            this.widget.task.setDateTime(date, time);
            this.widget.callback();
            Navigator.pop(context);
            },
        )
      ],
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: this.widget.task.isReminderSet ? this.widget.task.date : DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != this.widget.task.date)
      setState(() {
        date = picked;
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: this.widget.task.isReminderSet ? this.widget.task.time : TimeOfDay.now(),
    );
    if (picked != null && picked != this.widget.task.time)
      setState(() {
        time = picked;
      });
  }

}