import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  final VoidCallback? onTaskSaved; // Improved type safety

  const TaskForm({this.task, this.onTaskSaved});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;
  bool _enableReminder = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _dueDate = widget.task!.dueDate;
      _dueTime = TimeOfDay.fromDateTime(widget.task!.dueDate);
      if (widget.task!.reminderTime != null) {
        _enableReminder = true;
        _reminderDate = widget.task!.reminderTime!;
        _reminderTime = TimeOfDay.fromDateTime(widget.task!.reminderTime!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add New Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              _buildDateTimeField(
                  'Due Date & Time', _dueDate, _dueTime, _updateDueDateTime),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _enableReminder,
                    onChanged: (value) =>
                        setState(() => _enableReminder = value ?? false),
                  ),
                  Text('Set Reminder'),
                ],
              ),
              if (_enableReminder) ...[
                SizedBox(height: 16),
                _buildDateTimeField(
                  'Reminder Time',
                  _reminderDate ?? _dueDate,
                  _reminderTime ?? _dueTime,
                  _updateReminderDateTime,
                ),
                SizedBox(height: 8),
                if (_isReminderAfterDue())
                  Text(
                    'Warning: Reminder is set after due date',
                    style: TextStyle(color: Colors.orange),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: Text('Save'),
        ),
      ],
    );
  }

  Widget _buildDateTimeField(String label, DateTime date, TimeOfDay time,
      Function(DateTime, TimeOfDay) onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectDate(context, (selectedDate) {
                  onUpdate(selectedDate, time);
                }, date),
                child: Text('${date.day}/${date.month}/${date.year}'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectTime(context, (selectedTime) {
                  onUpdate(date, selectedTime);
                }, time),
                child: Text(
                    '${time.hour}:${time.minute.toString().padLeft(2, '0')}'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context,
      Function(DateTime) onDateSelected, DateTime initialDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _selectTime(BuildContext context,
      Function(TimeOfDay) onTimeSelected, TimeOfDay initialTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  void _updateDueDateTime(DateTime date, TimeOfDay time) {
    setState(() {
      _dueDate = date;
      _dueTime = time;
    });
  }

  void _updateReminderDateTime(DateTime date, TimeOfDay time) {
    setState(() {
      _reminderDate = date;
      _reminderTime = time;
    });
  }

  bool _isReminderAfterDue() {
    if (!_enableReminder || _reminderDate == null || _reminderTime == null) {
      return false;
    }

    final reminderDateTime = DateTime(
      _reminderDate!.year,
      _reminderDate!.month,
      _reminderDate!.day,
      _reminderTime!.hour,
      _reminderTime!.minute,
    );

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    return reminderDateTime.isAfter(dueDateTime);
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );

      DateTime? reminderDateTime;
      if (_enableReminder && _reminderDate != null && _reminderTime != null) {
        reminderDateTime = DateTime(
          _reminderDate!.year,
          _reminderDate!.month,
          _reminderDate!.day,
          _reminderTime!.hour,
          _reminderTime!.minute,
        );
      }

      final task = Task(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        dueDate: dueDateTime,
        reminderTime: reminderDateTime,
        isCompleted: widget.task?.isCompleted ?? false,
      );

      await StorageService().saveTask(task);

      widget.onTaskSaved?.call(); // Safer call

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task saved successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
