import 'dart:convert'; // Added for jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    return tasksJson
        .map((json) => Task.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    final existingIndex = tasks.indexWhere((t) => t.id == task.id);

    if (existingIndex >= 0) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }

    await _saveAllTasks(tasks);
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await _saveAllTasks(tasks);
  }

  Future<void> _saveAllTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList(); // Fixed: use jsonEncode
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }
}
