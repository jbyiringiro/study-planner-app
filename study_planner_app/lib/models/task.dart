class Task {
  final String id;
  String title;
  String? description;
  DateTime dueDate;
  DateTime? reminderTime;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.reminderTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}