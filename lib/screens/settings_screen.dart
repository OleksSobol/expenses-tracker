// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'categories_screen.dart';
import 'help_support_screen.dart';
import '../services/export_service.dart';
import '../services/permission_service.dart';
import '../services/db_service.dart';
import '../widgets/settings_card.dart';
import '../widgets/dialogs/theme_dialog.dart';
import '../widgets/dialogs/export_dialog.dart';
import '../widgets/dialogs/clear_data_dialog.dart';
import '../widgets/dialogs/about_dialog.dart';
import '../widgets/dialogs/generic_dialogs.dart';

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
  bool _isExporting = false;
  bool _isClearing = false;
  bool _hasStoragePermission = false;

  final ExportService _exportService = ExportService();
  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {
    final hasPermission = await _permissionService.checkStoragePermission();
    setState(() {
      _hasStoragePermission = hasPermission;
    });
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

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      await _exportService.exportAllData(
        hasStoragePermission: _hasStoragePermission,
        onSuccess: (locationMessage, fullPath, timestamp) {
          _exportService.showExportSuccessDialog(
            context: context,
            locationMessage: locationMessage,
            fullPath: fullPath,
            timestamp: timestamp,
          );
        },
        onError: (message) {
          GenericDialogs.showErrorDialog(context, message);
        },
      );
    } catch (e) {
      GenericDialogs.showErrorDialog(context, 'Failed to export data: ${e.toString()}');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _requestStoragePermission() async {
    final status = await _permissionService.requestStoragePermission();
    final granted = status.isGranted;
    setState(() {
      _hasStoragePermission = granted as bool;
    });
    
    if (granted) {
      GenericDialogs.showSuccessDialog(
        context, 
        'Storage permission granted! Exported files will now be saved to your Downloads folder.'
      );
    } else {
      GenericDialogs.showErrorDialog(
        context, 
        'Storage permission denied. Files will be saved to app storage only.'
      );
    }
  }

  Future<void> _clearAllData() async {
    setState(() {
      _isClearing = true;
    });

    try {
      final db = DBService();
      
      // Clear all tables
      await db.clearTable('transactions');
      await db.clearTable('bills');
      await db.clearTable('categories');

      GenericDialogs.showSuccessDialog(context, 'All data cleared successfully!');
      
    } catch (e) {
      GenericDialogs.showErrorDialog(context, 'Failed to clear data: ${e.toString()}');
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  void _showThemeDialog() {
    ThemeDialog.show(
      context: context,
      currentThemeMode: _currentThemeMode,
      onThemeChanged: _changeTheme,
    );
  }

  void _showExportDialog() {
    ExportDialog.show(
      context: context,
      hasStoragePermission: _hasStoragePermission,
      onConfirm: _exportData,
    );
  }

  void _showClearDataDialog() {
    ClearDataDialog.show(
      context: context,
      onConfirm: _clearAllData,
    );
  }

  void _showAboutDialog() {
    AboutAppDialog.show(context);
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
          SettingsCard(
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
          SettingsCard(
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
            onTap: _showThemeDialog,
          ),
          SizedBox(height: 8),
          SettingsCard(
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
            onTap: () => GenericDialogs.showComingSoonDialog(context, 'Currency Settings'),
          ),

          SizedBox(height: 24),

          // Data Section
          _buildSectionHeader('Data & Backup'),
          // Storage Permission Card (Android only)
          if (Platform.isAndroid) ...[
            SettingsCard(
              icon: _hasStoragePermission ? Icons.check_circle : Icons.folder,
              title: 'Storage Access',
              subtitle: _hasStoragePermission 
                  ? 'Storage permission granted - files save to Downloads' 
                  : 'Grant permission to save exports to Downloads folder',
              onTap: _hasStoragePermission ? null : _requestStoragePermission,
              trailing: _hasStoragePermission 
                  ? Icon(Icons.check, color: Colors.green)
                  : null,
              textColor: _hasStoragePermission ? Colors.green : null,
            ),
            SizedBox(height: 8),
          ],
          SettingsCard(
            icon: Icons.cloud_upload,
            title: 'Export Data',
            subtitle: _isExporting 
                ? 'Exporting data...' 
                : 'Export your transactions, bills, and categories to CSV',
            onTap: _isExporting ? null : _showExportDialog,
            trailing: _isExporting 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          SizedBox(height: 8),
          SettingsCard(
            icon: Icons.cloud_download,
            title: 'Import Data',
            subtitle: 'Import transactions from CSV file',
            onTap: () => GenericDialogs.showComingSoonDialog(context, 'Import Data'),
          ),
          SizedBox(height: 8),
          SettingsCard(
            icon: Icons.delete_sweep,
            title: 'Clear All Data',
            subtitle: _isClearing 
                ? 'Clearing data...' 
                : 'Delete all transactions, bills, and categories',
            onTap: _isClearing ? null : _showClearDataDialog,
            textColor: Colors.red,
            trailing: _isClearing 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )
                : null,
          ),

          SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          SettingsCard(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: _showAboutDialog,
          ),
          SizedBox(height: 8),
          SettingsCard(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help or contact us with questions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpSupportScreen()),
            ),
          ),
          SizedBox(height: 8),
          SettingsCard(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () => GenericDialogs.showComingSoonDialog(context, 'Privacy Policy'),
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
}