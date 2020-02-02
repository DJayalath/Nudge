import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'task.dart';

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
    final List<Task> tasks = [];

    try {
      // Get the file to read.
      final file = await _localFile;

      // Read each line of the file.
      final contents = await file.readAsLines();

      for (String line in contents) {

        // Split by commas (file is formatted as lines of comma-separated variables).
        final parts = line.split(',');

        // Create a new task instance with the title, [parts[0]], body [[parts[1]], and id [[parts[6]].
        final task = Task(parts[0], parts[1], parts[6]);

        // Check if a reminder, [[parts[3]] is set.
        if (parts[3] == "T") {
          task.setDateTime(
            DateTime.fromMillisecondsSinceEpoch(int.parse(parts[2])),
          );
        }

        // Check if the task has been completed - [[parts[4]].
        if (parts[4] == "T") task.toggleComplete();

        // Set early reminders
        if (parts[5] != "F") {
          task.setEarlyReminder(Duration(minutes: int.parse(parts[5])));
        }

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

    var tasksStringFormatted = "";

    for (Task task in tasks) {

      // Build string from member variables of [Task] object.
      tasksStringFormatted += "${task.title},"
          "${task.body},"
          "${task.isReminderSet ? task.date.millisecondsSinceEpoch : "F"},"
          "${task.isReminderSet ? "T" : "F"},"
          "${task.isComplete ? "T" : "F"},"
          "${task.isEarlyReminderSet ?  task.earlyReminder.inMinutes : "F"}"
          "${task.id}"
          "\n";

    }

    // Write the string to the file on disk (ensuring overwrite).
    await file.writeAsString(tasksStringFormatted, mode: FileMode.writeOnly);
  }
}
