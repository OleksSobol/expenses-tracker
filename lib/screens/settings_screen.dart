// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({
    Key? key,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'system';
    
    setState(() {
      switch (themeString) {
        case 'light':
          _currentThemeMode = ThemeMode.light;
          break;
        case 'dark':
          _currentThemeMode = ThemeMode.dark;
          break;
        default:
          _currentThemeMode = ThemeMode.system;
      }
    });
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    
    await prefs.setString('theme_mode', themeString);
  }

  void _changeTheme(ThemeMode mode) async {
    setState(() {
      _currentThemeMode = mode;
    });
    
    await _saveThemePreference(mode);
    widget.onThemeChanged(mode);
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
  }) {
    final isSelected = _currentThemeMode == mode;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected 
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () => _changeTheme(mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose how the app looks',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24),
            
            _buildThemeOption(
              title: 'Light Theme',
              subtitle: 'Always use light mode',
              icon: Icons.light_mode,
              mode: ThemeMode.light,
            ),
            SizedBox(height: 12),
            
            _buildThemeOption(
              title: 'Dark Theme',
              subtitle: 'Always use dark mode',
              icon: Icons.dark_mode,
              mode: ThemeMode.dark,
            ),
            SizedBox(height: 12),
            
            _buildThemeOption(
              title: 'System Theme',
              subtitle: 'Follow system setting',
              icon: Icons.auto_mode,
              mode: ThemeMode.system,
            ),
            
            SizedBox(height: 32),
            
            Spacer(),
            
          ],
        ),
      ),
    );
  }
}