import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/task.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/task_list.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StorageService _storageService = StorageService();
  DateTime _selectedDate = DateTime.now();
  List<Task> _selectedDateTasks = [];
  List<Task> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _allTasks = await _storageService.getTasks();
    _updateSelectedDateTasks();
  }

  void _updateSelectedDateTasks() {
    setState(() {
      _selectedDateTasks = _allTasks.where((task) {
        final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
        final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        return taskDate == selected;
      }).toList();
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _updateSelectedDateTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: CalendarWidget(
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected,
              tasks: _allTasks,
            ),
          ),
          Divider(height: 1),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.list, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Tasks for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TaskList(
                    tasks: _selectedDateTasks,
                    onTaskUpdated: _loadTasks,
                    emptyMessage: 'No tasks for selected date',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}