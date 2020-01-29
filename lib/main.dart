import 'package:flutter/material.dart';

import 'package:flutter_nudge_reminders/task_list.dart';

/// Runs the app.
void main() {
  runApp(new NudgeApp());
}

/// The primary app class.
class NudgeApp extends StatelessWidget {
  /// Sets some basic app properties, the main app content is delegated to the [TaskList] route.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nudge',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: TaskList(),
    );
  }
}
