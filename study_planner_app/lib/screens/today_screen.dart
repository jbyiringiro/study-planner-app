import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/task.dart';
import '../widgets/task_list.dart';

class TodayScreen extends StatefulWidget {
  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  List<Task> _todayTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  Future<void> _loadTodayTasks() async {
    final allTasks = await _storageService.getTasks();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    setState(() {
      _todayTasks = allTasks.where((task) {
        final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
        return taskDate == today;
      }).toList();
    });
  }

  Widget _buildUpcomingReminders() {
    return FutureBuilder<List<Task>>(
      future: _notificationService.getUpcomingReminders(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final upcomingTasks = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Upcoming Reminders (Next Hour)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              ...upcomingTasks.map((task) => Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: Icon(Icons.notifications, color: Colors.blue),
                  title: Text(task.title),
                  subtitle: Text('Reminder: ${_formatDateTime(task.reminderTime!)}'),
                  trailing: Icon(Icons.access_time, color: Colors.blue),
                ),
              )).toList(),
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  _getFormattedDate(),
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          _buildUpcomingReminders(),
          Expanded(
            child: TaskList(
              tasks: _todayTasks,
              onTaskUpdated: _loadTodayTasks,
              emptyMessage: 'No tasks for today!',
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)} ${now.year}';
  }

  String _getWeekday(int weekday) {
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][weekday - 1];
  }

  String _getMonth(int month) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
  }
}