import 'package:flutter/material.dart';

import 'task_list.dart';

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
//      themeMode: ThemeMode.dark,
//      darkTheme: ThemeData(
////        primarySwatch: Colors.black45,
////        primarySwatch: Colors.grey,
//      colorScheme: ColorScheme.dark(),
//      ),
      title: 'Nudge',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: TaskList(),
    );
  }
}
