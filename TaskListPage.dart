import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/task.dart';

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _taskList = [];

  @override
  void initState() {
    super.initState();
    _queryTasks();
  }

  void _queryTasks() async {
    final List<Map<String, dynamic>> taskMaps = await DBHelper.queryTask();
    setState(() {
      _taskList = taskMaps.map((map) => Task.fromJson(map)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: ListView.builder(
        itemCount: _taskList.length,
        itemBuilder: (context, index) {
          final Task task = _taskList[index];
          return ListTile(
            title: Text(task.title ?? ''),
            subtitle: Text('${task.date}${task.type}${task.duration} ${task.startTime} - ${task.endTime}'),
          );
        },
      ),

    );
  }


}
