// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'categories_screen.dart';
import 'help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
  });

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

  String _getThemeModeText() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Categories Section
          _buildSectionHeader('Categories'),
          _buildSettingsCard(
            icon: Icons.category,
            title: 'Manage Categories',
            subtitle: 'Add, edit, or delete transaction categories',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriesScreen()),
              );
              if (result == true) {
                setState(() {}); // Refresh if needed
              }
            },
          ),

          SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSettingsCard(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Currently using ${_getThemeModeText()} theme',
            trailing: Text(
              _getThemeModeText(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _showThemeDialog(),
          ),
          SizedBox(height: 8),
          _buildSettingsCard(
            icon: Icons.language,
            title: 'Currency',
            subtitle: 'Change currency symbol and format',
            trailing: Text(
              'USD (\$)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _showComingSoonDialog(context, 'Currency Settings'),
          ),

          SizedBox(height: 24),

          // Data Section
          _buildSectionHeader('Data & Backup'),
          _buildSettingsCard(
            icon: Icons.cloud_upload,
            title: 'Export Data',
            subtitle: 'Export your transactions to CSV',
            onTap: () => _showComingSoonDialog(context, 'Export Data'),
          ),
          SizedBox(height: 8),
          _buildSettingsCard(
            icon: Icons.cloud_download,
            title: 'Import Data',
            subtitle: 'Import transactions from CSV file',
            onTap: () => _showComingSoonDialog(context, 'Import Data'),
          ),
          SizedBox(height: 8),
          _buildSettingsCard(
            icon: Icons.delete_sweep,
            title: 'Clear All Data',
            subtitle: 'Delete all transactions and categories',
            onTap: () => _showClearDataDialog(context),
            textColor: Colors.red,
          ),

          SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          _buildSettingsCard(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => _showAboutDialog(context),
          ),
          SizedBox(height: 8),
          _buildSettingsCard(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help or contact us with questions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpSupportScreen()),
            ),
          ),
          SizedBox(height: 8),
          _buildSettingsCard(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () => _showComingSoonDialog(context, 'Privacy Policy'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Widget? trailing,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (textColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: textColor ?? Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              title: 'Light Theme',
              subtitle: 'Always use light mode',
              icon: Icons.light_mode,
              mode: ThemeMode.light,
            ),
            SizedBox(height: 8),
            _buildThemeOption(
              title: 'Dark Theme',
              subtitle: 'Always use dark mode',
              icon: Icons.dark_mode,
              mode: ThemeMode.dark,
            ),
            SizedBox(height: 8),
            _buildThemeOption(
              title: 'System Theme',
              subtitle: 'Follow system setting',
              icon: Icons.auto_mode,
              mode: ThemeMode.system,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
  }) {
    final isSelected = _currentThemeMode == mode;
    
    return InkWell(
      onTap: () {
        _changeTheme(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content: Text('$feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text(
          'This will permanently delete all your transactions and categories. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Feature coming soon - data clearing will be implemented'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Clear Data', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Expenses Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.account_balance_wallet, size: 48),
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'A simple and efficient way to track your income and expenses. Organize your transactions with custom categories and get insights into your spending habits.',
          ),
        ),
      ],
    );
  }
}