import 'package:flutter/material.dart';
import 'screens/today_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';
import 'widgets/task_form.dart';

void main() {
  runApp(StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    TodayScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check for reminders when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkReminders();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check for reminders when app comes to foreground
      _checkReminders();
    }
  }

  void _checkReminders() {
    _notificationService.checkAndShowReminders(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Check reminders when switching screens
          _checkReminders();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex != 2 ? FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ) : null,
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskForm(onTaskSaved: () {
        // Check for new reminders after adding a task
        _checkReminders();
      }),
    ).then((_) => _checkReminders());
  }
}