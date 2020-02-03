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

  static const _DROP_DOWN_MINUTES = ['5', '15', '30', '45'];
  static const _DROP_DOWN_HOURS = ['1', '2', '4', '6'];

  /// The date of the task.
  var date = DateTime.now();

  /// The time of the task.
  var time = TimeOfDay.now();

  /// Early reminder status
  var earlyReminder = false;

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

  var _dropDownValue = _DROP_DOWN_MINUTES[0];
  List<String> _dropDownValues = _DROP_DOWN_MINUTES;
  var _dropDownTime = 'minutes';

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
          title: Text(
              "Early reminder?",
//            style: TextStyle(fontSize: 14),
          ),
          value: earlyReminder,
          onChanged: (bool value) {
            setState(() {
              earlyReminder = value;
            });
          },
        ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: DropdownButton<String>(
                  value: _dropDownValue,
                  disabledHint: Text("$_dropDownValue"),
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 20,
                  elevation: 16,
                  onChanged: !earlyReminder ? null : (String newValue) {
                    setState(() {
                      _dropDownValue = newValue;
                    });
                  },
                  items: _dropDownValues
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text("$value", textAlign: TextAlign.center,),
                    );
                  }).toList(),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: DropdownButton<String>(
                  value: _dropDownTime,
                  disabledHint: Text("$_dropDownTime"),
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 20,
                  elevation: 16,
                  onChanged: !earlyReminder ? null : (String newValue) {
                    setState(() {
                      _dropDownTime = newValue;

                      if (_dropDownTime == "minutes") {
                        _dropDownValue = _DROP_DOWN_MINUTES[0];
                        _dropDownValues = _DROP_DOWN_MINUTES;
                      } else {
                        _dropDownValue = _DROP_DOWN_HOURS[0];
                        _dropDownValues = _DROP_DOWN_HOURS;
                      }

                    });
                  },
                  items: <String>['hours', 'minutes']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text("$value", textAlign: TextAlign.center,),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

        ButtonBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                widget.task.resetEarlyReminder();
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
                    // Must set early reminder BEFORE actual reminder because actual reminder method sets notification.
                    if (earlyReminder) {
                      var duration = Duration(minutes: ((_dropDownTime == "minutes") ? 1 : 60) * int.parse(_dropDownValue));
                      widget.task.setEarlyReminder(duration);
                    } else {
                      widget.task.resetEarlyReminder();
                    }
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
  ///
  /// This also handles early reminder state loading if it has been set for the task.
  @override
  void initState() {
    // Check that a reminder has been set first.
    if (widget.task.isReminderSet) {
      date = DateTime(widget.task.date.year, widget.task.date.month, widget.task.date.day);
      time = TimeOfDay(hour: widget.task.date.hour, minute: widget.task.date.minute);
      if (widget.task.isEarlyReminderSet) {
        earlyReminder = true;
        var duration = widget.task.earlyReminder.inMinutes;
        if (duration > 45) {
          _dropDownTime = "hours";
          _dropDownValue = "${duration ~/ 60}";
          _dropDownValues = _DROP_DOWN_HOURS;
        } else {
          _dropDownTime = "minutes";
          _dropDownValue = "$duration";
          _dropDownValues = _DROP_DOWN_MINUTES;
        }
      }
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
