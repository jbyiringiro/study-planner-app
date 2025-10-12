import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:uuid/uuid.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  DateTime _dueDate = DateTime.now();
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _reminderTime = widget.task!.reminderTime;
    } else {
      _title = '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<TaskProvider>(context, listen: false);
      final id = widget.task?.id ?? const Uuid().v4();
      final newTask = Task(
        id: id,
        title: _title,
        description: _description,
        dueDate: _dueDate,
        reminderTime: _reminderTime,
      );
      if (widget.task == null) {
        await provider.addTask(newTask);
      } else {
        await provider.updateTask(newTask);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Title required' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value,
              ),
              ListTile(
                title: Text('Due Date: ${_dueDate.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SwitchListTile(
                title: const Text('Set Reminder'),
                value: _reminderTime != null,
                onChanged: (val) {
                  setState(() {
                    if (val) {
                      _reminderTime = TimeOfDay.now();
                    } else {
                      _reminderTime = null;
                    }
                  });
                },
              ),
              if (_reminderTime != null)
                ListTile(
                  title: Text('Reminder Time: ${_reminderTime!.format(context)}'),
                  trailing: Icon(Icons.access_time),
                  onTap: () => _selectTime(context),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
