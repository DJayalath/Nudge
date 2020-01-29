import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_nudge_reminders/task.dart';
import 'package:path_provider/path_provider.dart';

/// A helper for reading/writing tasks to disk.
class TaskIO {
  /// Gets the file to which tasks will be read from or saved to.
  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tasks.txt');
  }

  /// Gets the persistent documents directory of the device.
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Reads tasks from disk.
  static Future<List<Task>> readTasks() async {
    final tasks = [];

    try {
      // Get the file to read.
      final file = await _localFile;

      // Read each line of the file.
      List<String> contents = await file.readAsLines();

      for (String line in contents) {

        // Split by commas (file is formatted as lines of comma-separated variables).
        List<String> parts = line.split(',');

        // Create a new task instance with the title, [parts[0]], and body [[parts[1]].
        Task task = Task(parts[0], parts[1]);

        // Check if a reminder, [[parts[5]] is set.
        if (parts[5] == "T") {
          task.setDateTime(
            DateTime.fromMillisecondsSinceEpoch(int.parse(parts[2])),
            TimeOfDay(hour: int.parse(parts[3]), minute: int.parse(parts[4])),
          );
        }

        // Check if the task has been completed - [[parts[6]].
        if (parts[6] == "T") task.toggleComplete();

        // Add the task to the working list.
        tasks.add(task);
      }

      return tasks;

    } catch (e) {

      // If no such directory/file exists, just return an empty list.
      return tasks;
    }
  }

  /// Writes [tasks] to disk.
  static void writeTasks(List<Task> tasks) async {

    // Get the file to write.
    final file = await _localFile;

    String tasksString = "";

    for (Task task in tasks) {

      // Build string from member variables of [Task] object.
      tasksString += "${task.title},"
          "${task.body},"
          "${task.isReminderSet ? task.date.millisecondsSinceEpoch : "F"},"
          "${task.isReminderSet ? task.time.hour : "F"},"
          "${task.isReminderSet ? task.time.minute : "F"},"
          "${task.isReminderSet ? "T" : "F"},"
          "${task.isComplete ? "T" : "F"}"
          "\n";

    }

    // Write the string to the file on disk (ensuring overwrite).
    await file.writeAsString(tasksString, mode: FileMode.writeOnly);
  }
}
