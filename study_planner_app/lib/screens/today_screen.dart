import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';


class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  bool _reminderShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reminderShown) {
      final todayTasks = context.watch<TaskProvider>().todayTasks();
      final now = TimeOfDay.now();
      for (final task in todayTasks) {
        if (task.reminderTime != null &&
            task.reminderTime!.hour == now.hour &&
            task.reminderTime!.minute == now.minute) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Reminder'),
                content: Text('It\'s time for: ${task.title}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
          _reminderShown = true;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = context.watch<TaskProvider>().todayTasks();
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: todayTasks.length,
                itemBuilder: (context, index) {
                  final task = todayTasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.description ?? ''),
                    trailing: Text(
                      '${task.dueDate.hour}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskFormScreen(task: task),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskFormScreen(),
                  ),
                );
              },
              child: const Text('New Task'),
            ),
          ],
        ),
      ),
    );
  }
}
