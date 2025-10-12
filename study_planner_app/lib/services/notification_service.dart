import 'package:flutter/material.dart';
import '../models/task.dart';
import 'storage_service.dart';

class NotificationService {
  final StorageService _storageService = StorageService();

  Future<void> checkAndShowReminders(BuildContext context) async {
    final notificationsEnabled = await _storageService.getNotificationsEnabled();
    if (!notificationsEnabled) return;

    final tasks = await _storageService.getTasks();
    final now = DateTime.now();
    
    for (final task in tasks) {
      if (task.reminderTime != null && 
          !task.isCompleted &&
          _shouldShowReminder(task.reminderTime!, now)) {
        _showReminderDialog(context, task);
      }
    }
  }

  bool _shouldShowReminder(DateTime reminderTime, DateTime now) {
    // Show reminder if it's within the current minute
    return reminderTime.year == now.year &&
           reminderTime.month == now.month &&
           reminderTime.day == now.day &&
           reminderTime.hour == now.hour &&
           reminderTime.minute == now.minute;
  }

  void _showReminderDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.blue),
            SizedBox(width: 8),
            Text('Task Reminder'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (task.description != null) Text(task.description!),
            SizedBox(height: 8),
            Text(
              'Due: ${_formatDateTime(task.dueDate)}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Dismiss'),
          ),
          TextButton(
            onPressed: () {
              _markAsComplete(context, task);
              Navigator.of(context).pop();
            },
            child: Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsComplete(BuildContext context, Task task) async {
    final completedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      reminderTime: task.reminderTime,
      isCompleted: true,
    );
    
    await _storageService.saveTask(completedTask);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task marked as complete')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Schedule reminder check when app starts or becomes active
  void scheduleReminderCheck(BuildContext context) {
    // Check immediately when called
    checkAndShowReminders(context);
    
    // Check every minute (simulated)
    _startPeriodicCheck(context);
  }

  void _startPeriodicCheck(BuildContext context) {
    // In a real app, you would use a timer or background service
    // For this implementation, we'll rely on app open and screen changes
    // This is a simplified version for the assignment requirements
  }

  // Check for upcoming reminders (within next hour)
  Future<List<Task>> getUpcomingReminders() async {
    final tasks = await _storageService.getTasks();
    final now = DateTime.now();
    final oneHourFromNow = now.add(Duration(hours: 1));
    
    return tasks.where((task) {
      return task.reminderTime != null &&
             !task.isCompleted &&
             task.reminderTime!.isAfter(now) &&
             task.reminderTime!.isBefore(oneHourFromNow);
    }).toList();
  }
}