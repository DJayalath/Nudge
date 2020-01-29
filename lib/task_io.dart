import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_nudge_reminders/task.dart';

class TaskIO {

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tasks.txt');
  }

  static Future<List<String>> _readLines(File file) async {
    return file.readAsLines();
  }

  static void writeTasks(List<Task> tasks) async {

    final file = await _localFile;
//    file.delete();

    String tasksString = "";

    // Build string
    for (Task task in tasks) {
      tasksString += "${task.getTitle()},"
          "${task.getBody()},"
          "${task.shouldRemind() ? task.getDate().millisecondsSinceEpoch : "F"},"
          "${task.shouldRemind() ? task.getTime().hour : "F"},"
          "${task.shouldRemind() ? task.getTime().minute : "F"},"
          "${task.shouldRemind() ? "T" : "F"},"
          "${task.isComplete() ? "T" : "F"}"
          "\n";
    }

    // Write the file.
    await file.writeAsString(tasksString, mode: FileMode.writeOnly);
    debugPrint("Wrote files");
  }

  // TODO: Check file exists, moron!
  static Future<List<Task>> readTasks() async {

    List<Task> tasks = [];

    try {
      final file = await _localFile;

      // Read the file.
      List<String> contents = await _readLines(file);
      for (String line in contents) {

        debugPrint("Read: " + line);

        List<String> parts = line.split(',');
        Task task = Task(parts[0], parts[1]);

        if (parts[5] == "T") {
          task.setDateTime(
            DateTime.fromMillisecondsSinceEpoch(int.parse(parts[2])),
            TimeOfDay(hour: int.parse(parts[3]), minute: int.parse(parts[4])),
          );
        }

        if (parts[6] == "T")
          task.toggleComplete();

        tasks.add(task);
      }

      return tasks;
    } catch (e) {
      debugPrint("Failed to read file");
      // TODO: If encountering an error, do something.
      return tasks;
    }
  }



}