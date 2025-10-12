import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasksForSelectedDay = _selectedDay != null
        ? taskProvider.tasksForDate(_selectedDay!)
        : [];
    final allTasks = taskProvider.tasks;
    final markedDates = allTasks.map((t) => DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day)).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('My Study Planner')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final isMarked = markedDates.contains(DateTime(day.year, day.month, day.day));
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: isMarked ? Colors.yellow[700] : null,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(child: Text('${day.day}')),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasksForSelectedDay.length,
              itemBuilder: (context, index) {
                final task = tasksForSelectedDay[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description ?? ''),
                  trailing: Text(
                    '${task.dueDate.hour}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
