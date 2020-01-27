import 'package:flutter/material.dart';

import 'package:flutter_nudge_reminders/task_list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(new NudgeApp());
}

class NudgeApp extends StatelessWidget {

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