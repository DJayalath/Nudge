import 'package:flutter/material.dart';

void main() => runApp(new NudgeApp());

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

class TaskList extends StatefulWidget {

  @override
  _TaskListState createState() => _TaskListState();

}

class _TaskListState extends State<TaskList> {

  static List<Task> tasks = [];
  final _dateTimeStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w300,
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        appBar: AppBar(
            title: Text('Nudge Tasks')
        ),

        // Display list of cards of tasks
        body: _buildContent(),

        // The 'add new task' button
        floatingActionButton: FloatingActionButton(
          onPressed: _pushAddTaskRoute,
          tooltip: 'New task',
          child: Icon(Icons.note_add),
        ),


    );

  }

  // Pushes add task route
  void _pushAddTaskRoute() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddTask(this.callback)),
    );
  }

  void _editTaskRoute(task, index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTask(this.callback, task, index)),
    );
  }

  Widget _buildContent() {

    return Container(
      margin: EdgeInsets.all(5.0),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: tasks.length,
          // Make cards
          itemBuilder: (context, i) {
            return Dismissible(

              key: Key(tasks[i]._title),

              background: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                color: Colors.red,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Icon(
                      Icons.delete
                    ),
                  ),
                )
              ),

              direction: DismissDirection.startToEnd,

              onDismissed: (direction){

                // Remove from tasks
                setState(() {
                  tasks.removeAt(i);
                });

                // Show a snackbar. This snackbar could also contain "Undo" actions.
                Scaffold
                    .of(context)
                    .showSnackBar(
                      SnackBar(
                          content: Text("Task dismissed"),
                          duration: Duration(seconds: 2),
                      )
                );
              },

              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: InkWell(

                  onTap: () => _editTaskRoute(tasks[i], i),

                  child: Container(
  //                decoration: ,
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            tasks[i]._title,
                            style: tasks[i]._complete ? TextStyle(decoration: TextDecoration.lineThrough) : null,
                          ),
                          subtitle: (tasks[i]._body != "") ? Text(tasks[i]._body) : null,
                          leading: IconButton(
                            icon: Icon(tasks[i]._complete ? Icons.check_box : Icons.check_box_outline_blank),
                            onPressed: () {
                              setState(() {
                                tasks[i]._complete = !tasks[i]._complete;
                              });
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.alarm_add),
                            onPressed: () {

                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(i);
                                }
                              );
                            },
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.alarm_on),
                          title: Text(
                            tasks[i]._selectedTime.format(context),
                            style: _dateTimeStyle,
                          ),
                          trailing: Text(
                            tasks[i]._selectedDate.toString().split(' ')[0],
                            style: _dateTimeStyle,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );

  }

  void callback() {
    setState(() {});
  }

}

class AlertDialog extends StatefulWidget {

  final i;
  AlertDialog(this.i);

  @override
  _AlertDialogState createState() => new _AlertDialogState();
}

class _AlertDialogState extends State<AlertDialog> {

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select date/time'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () => _selectDate(context, this.widget.i),
          child: Text("${_TaskListState.tasks[this.widget.i]._selectedDate.toLocal()}".split(' ')[0]),
        ),
        SimpleDialogOption(
          onPressed: () => _selectTime(context, this.widget.i),
          child: Text("${_TaskListState.tasks[this.widget.i]._selectedTime.format(context)}"),
        ),
      ],
    );
  }

  Future<Null> _selectDate(BuildContext context, index) async {
    Task task = _TaskListState.tasks[index];
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: task._selectedDate != DateTime(2015, 8) ? task._selectedDate : DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
    );
    if (picked != null && picked != _TaskListState.tasks[index]._selectedDate)
      setState(() {
        _TaskListState.tasks[index]._selectedDate = picked;
      });
  }

  Future<Null> _selectTime(BuildContext context, index) async {
    Task task = _TaskListState.tasks[index];
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: task._selectedTime != TimeOfDay(hour: 0, minute: 0) ? task._selectedTime : TimeOfDay.now(),
    );
    if (picked != null && picked != task._selectedTime)
      setState(() {
        task._selectedTime = picked;
      });
  }

}

class Task {

  final _title;
  final _body;
  var _complete = false;
  var _selectedDate = DateTime(2015, 8);
  var _selectedTime = TimeOfDay(hour: 0, minute: 0);

  Task(this._title, this._body);
}

class EditTask extends AddTask {

  final _task;
  final _index;
  EditTask(_callback, this._task, this._index) : super(_callback);

  @override
  _EditTaskState createState() => _EditTaskState(_task, _index);
}

class _EditTaskState extends _AddTaskState {

  final index;
  final task;

  _EditTaskState(this.task, this.index) {
    _titleController = TextEditingController(text: task._title);
    _bodyController = TextEditingController(text: task._body);
  }

  @override
  void _saveTask(task) {
    _TaskListState.tasks[index] = task;
    this.widget._callback();
    Navigator.pop(context);
  }

}

class AddTask extends StatefulWidget {

  final _callback;
  AddTask(this._callback);

  @override
  _AddTaskState createState() => _AddTaskState();

}

class _AddTaskState extends State<AddTask> {

  var _titleController = TextEditingController();
  var _bodyController = TextEditingController();

  void _saveTask(task) {
    _TaskListState.tasks.add(task);
    this.widget._callback();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
          title: Text('Add New Task')
      ),

      body: Center(

        child: Card(
          margin: EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              // Title entry
              ListTile(
                leading: Icon(Icons.title),
                title: TextField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter title'
                  ),
                ),
              ),

              // Checkbox to remind X minutes early
              ListTile(
                leading: Icon(Icons.check_box_outline_blank),
                title: Text("Remind me 10 minutes early?"),
                onTap: null,
              ),

              // Optional body entry
              Expanded(
                child:
                  ListTile(
                    title: TextField(
                      controller: _bodyController,
                      autofocus: false,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter optional details'
                      ),
                    ),
                  ),
              ),

              // Save/Delete task button bar
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ButtonBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.centerLeft,
                        icon: Icon(Icons.alarm_add),
                        onPressed: null,
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            alignment: Alignment.centerRight,
                            icon: Icon(Icons.delete),
                            onPressed: null,
                          ),
                          FlatButton(
                            child: const Text('SAVE'),
                            onPressed: () => _saveTask(
                                Task(_titleController.text, _bodyController.text)
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        )
      );

  }

}

//import 'package:flutter/material.dart';
//
//void main() => runApp(MyApp());
//
//class MyApp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Flutter Demo',
//      theme: ThemeData(
//        // This is the theme of your application.
//        //
//        // Try running your application with "flutter run". You'll see the
//        // application has a blue toolbar. Then, without quitting the app, try
//        // changing the primarySwatch below to Colors.green and then invoke
//        // "hot reload" (press "r" in the console where you ran "flutter run",
//        // or simply save your changes to "hot reload" in a Flutter IDE).
//        // Notice that the counter didn't reset back to zero; the application
//        // is not restarted.
//        primarySwatch: Colors.blue,
//      ),
//      home: MyHomePage(title: 'Flutter Demo Home Page'),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//  MyHomePage({Key key, this.title}) : super(key: key);
//
//  // This widget is the home page of your application. It is stateful, meaning
//  // that it has a State object (defined below) that contains fields that affect
//  // how it looks.
//
//  // This class is the configuration for the state. It holds the values (in this
//  // case the title) provided by the parent (in this case the App widget) and
//  // used by the build method of the State. Fields in a Widget subclass are
//  // always marked "final".
//
//  final String title;
//
//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      // This call to setState tells the Flutter framework that something has
//      // changed in this State, which causes it to rerun the build method below
//      // so that the display can reflect the updated values. If we changed
//      // _counter without calling setState(), then the build method would not be
//      // called again, and so nothing would appear to happen.
//      _counter++;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // This method is rerun every time setState is called, for instance as done
//    // by the _incrementCounter method above.
//    //
//    // The Flutter framework has been optimized to make rerunning build methods
//    // fast, so that you can just rebuild anything that needs updating rather
//    // than having to individually change instances of widgets.
//    return Scaffold(
//      appBar: AppBar(
//        // Here we take the value from the MyHomePage object that was created by
//        // the App.build method, and use it to set our appbar title.
//        title: Text(widget.title),
//      ),
//      body: Center(
//        // Center is a layout widget. It takes a single child and positions it
//        // in the middle of the parent.
//        child: Column(
//          // Column is also a layout widget. It takes a list of children and
//          // arranges them vertically. By default, it sizes itself to fit its
//          // children horizontally, and tries to be as tall as its parent.
//          //
//          // Invoke "debug painting" (press "p" in the console, choose the
//          // "Toggle Debug Paint" action from the Flutter Inspector in Android
//          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//          // to see the wireframe for each widget.
//          //
//          // Column has various properties to control how it sizes itself and
//          // how it positions its children. Here we use mainAxisAlignment to
//          // center the children vertically; the main axis here is the vertical
//          // axis because Columns are vertical (the cross axis would be
//          // horizontal).
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text(
//              'You have pushed the button this many times:',
//            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.display1,
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );
//  }
//}
