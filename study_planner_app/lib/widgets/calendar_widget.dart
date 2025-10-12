import 'package:flutter/material.dart';
import '../models/task.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<Task> tasks;

  const CalendarWidget({
    required this.selectedDate,
    required this.onDateSelected,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMonthHeader(),
          SizedBox(height: 16),
          _buildWeekdaysHeader(),
          SizedBox(height: 8),
          Expanded(child: _buildCalendarGrid()),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWeekdaysHeader() {
    return Row(
      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
          .map((day) => Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDay.weekday;
    final totalDays = lastDay.day;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: totalDays + firstWeekday,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return Container(); // Empty space before first day
        }

        final day = index - firstWeekday + 1;
        final currentDate = DateTime(selectedDate.year, selectedDate.month, day);
        final hasTasks = _hasTasksOnDate(currentDate);
        final isSelected = _isSameDay(currentDate, selectedDate);
        final isToday = _isSameDay(currentDate, DateTime.now());

        return GestureDetector(
          onTap: () => onDateSelected(currentDate),
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : (isToday ? Colors.blue.shade100 : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: isToday ? Border.all(color: Colors.blue) : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                if (hasTasks)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasTasksOnDate(DateTime date) {
    return tasks.any((task) => _isSameDay(task.dueDate, date));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String _getMonthName(int month) {
    return [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][month - 1];
  }
}