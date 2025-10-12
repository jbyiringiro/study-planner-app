import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationsEnabled =
        await _storageService.getNotificationsEnabled();
    setState(() {
      _notificationsEnabled = notificationsEnabled;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    await _storageService.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue),
              title: Text('Enable Notifications'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('About'),
              subtitle: Text('Study Planner App v1.0'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Study Planner',
                  applicationVersion: '1.0.0',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
