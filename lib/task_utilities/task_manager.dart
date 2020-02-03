import 'notification_scheduler.dart';
import 'task.dart';
import 'task_io.dart';

/// A maintainer of the tasks in the app.
///
/// Uses the singleton pattern and in addition to maintaining
/// all tasks, provides utilities for reading/writing
/// tasks and scheduling notifications.
class TaskManager {
  /// The singleton instance of the [TaskManager].
  static final TaskManager _singleton = TaskManager._internal();

  /// The list of tasks.
  List<Task> _tasks = [];

  /// The task list reader/writer.
  final taskIO = TaskIO();

  /// The notification scheduler.
  NotificationScheduler notificationScheduler;

  /// Returns the single instance.
  factory TaskManager() => _singleton;

  /// Private constructor.
  TaskManager._internal();

  /// Adds a task to the task list and returns a reference.
  Task createTask(title, body) {
    _tasks.add(Task(title, body, _generateUID()));
    updateIO();
    return _tasks.last;
  }

  /// Deletes notification scheduled.
  void deleteNotification(Task task) =>
      notificationScheduler.deleteNotification(task);

  /// Returns the task at the given index in [_tasks].
  Task getTask(index) => _tasks[index];

  /// Initialises by reading tasks.
  void init(callback) {
    // Read tasks.
    taskIO.readTasks().then((List<Task> readTasks) {
      // Assign read tasks to the maintained task list.
      _tasks = readTasks;

      // Initialise notification scheduler.
      notificationScheduler = NotificationScheduler();

      // Update task list on GUI.
      callback();
    });
  }

  /// Returns the length of the task list.
  int get length => _tasks.length;

  /// Removes a task from the task list.
  void removeTask(Task task) {
    deleteNotification(task);
    _tasks.remove(task);
    updateIO();
  }

  /// Removes a task from the task list by index.
  void removeTaskAt(index) {
    deleteNotification(_tasks[index]);
    _tasks.removeAt(index);
    updateIO();
  }

  /// Sorts tasks using comparator.
  void sort() => _tasks.sort(Task.sortTasks);

  /// Updates written data of tasks on disk.
  void updateIO() => taskIO.writeTasks(_tasks);

  /// Updates notification scheduling.
  void updateNotification(task) =>
      notificationScheduler.scheduleNotification(task);

  /// Generates a unique ID for a new task.
  ///
  /// Uses simple sequential ID generation to
  /// guarantee uniqueness.
  int _generateUID() {
    int maxID = 0;
    for (Task task in _tasks) {
      if (task.id > maxID) maxID = task.id;
    }
    return maxID + 1;
  }
}
