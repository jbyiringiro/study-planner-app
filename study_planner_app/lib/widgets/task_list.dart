import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_form.dart'; // Added import for TaskForm

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback onTaskUpdated;
  final String emptyMessage;

  const TaskList({
    required this.tasks,
    required this.onTaskUpdated,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(context, task);
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _toggleTaskCompletion(task, value ?? false),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(task.description!),
            SizedBox(height: 4),
            Text(
              'Due: ${_formatDateTime(task.dueDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (task.reminderTime != null)
              Text(
                'Reminder: ${_formatDateTime(task.reminderTime!)}',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteTask(context, task),
        ),
        onTap: () => _editTask(context, task),
      ),
    );
  }

  Future<void> _toggleTaskCompletion(Task task, bool isCompleted) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      reminderTime: task.reminderTime,
      isCompleted: isCompleted,
    );

    await StorageService().saveTask(updatedTask);
    onTaskUpdated();
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService().deleteTask(task.id);
      onTaskUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task deleted')),
      );
    }
  }

  void _editTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskForm(task: task, onTaskSaved: onTaskUpdated),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
