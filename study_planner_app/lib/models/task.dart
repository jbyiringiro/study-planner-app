import 'package:flutter/material.dart';

class Task {
  String id;
  String title;
  String? description;
  DateTime dueDate;
  TimeOfDay? reminderTime;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.reminderTime,
  });

  // For local storage (shared_preferences as JSON)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'reminderTime': reminderTime != null
            ? '${reminderTime!.hour}:${reminderTime!.minute}'
            : null,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final reminder = json['reminderTime'];
    TimeOfDay? reminderTime;
    if (reminder != null) {
      final parts = reminder.split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      reminderTime: reminderTime,
    );
  }
}
