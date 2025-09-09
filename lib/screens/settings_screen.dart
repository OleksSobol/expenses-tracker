import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text('Currency'),
            subtitle: Text('USD (\$)'),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('First day of month'),
            subtitle: Text('1st'),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Dark mode'),
            subtitle: Text('System default'),
          ),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup & Export'),
            subtitle: Text('Export CSV, enable backup'),
          ),
        ],
      ),
    );
  }
}
