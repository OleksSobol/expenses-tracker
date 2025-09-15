// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'categories_screen.dart';
import 'help_support_screen.dart';
import '../services/db_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      setState(() {
        _hasStoragePermission = status.isGranted;
      });
    } else {
      // iOS doesn't need special permission for app documents
      setState(() {
        _hasStoragePermission = true;
      });
    }
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

  Future<Directory?> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      if (_hasStoragePermission) {
        // Try Downloads directory first
        try {
          final downloadsDir = Directory('/storage/emulated/0/Download/ExpensesTracker');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          return downloadsDir;
        } catch (e) {
          // Fall back to external storage
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final expensesDir = Directory('${externalDir.path}/ExpensesTracker');
            if (!await expensesDir.exists()) {
              await expensesDir.create(recursive: true);
            }
            return expensesDir;
          }
        }
      } else {
        // Use app-specific storage without permission
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final expensesDir = Directory('${externalDir.path}/ExpensesTracker');
          if (!await expensesDir.exists()) {
            await expensesDir.create(recursive: true);
          }
          return expensesDir;
        }
      }
    } else {
      // iOS - use documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      final expensesDir = Directory('${documentsDir.path}/ExpensesTracker');
      if (!await expensesDir.exists()) {
        await expensesDir.create(recursive: true);
      }
      return expensesDir;
    }
    
    return null;
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final db = DBService();
      
      // Get all data
      final transactions = await db.queryAll('transactions');
      final bills = await db.queryAll('bills');
      final categories = await db.queryAll('categories');

      // Create CSV content for transactions
      String transactionsCsv = 'ID,Amount,Type,Category ID,Date,Note,Bill ID\n';
      for (final transaction in transactions) {
        transactionsCsv += '${transaction['id']},${transaction['amount']},${transaction['type']},${transaction['categoryId'] ?? ''},${transaction['date']},${transaction['note']?.replaceAll(',', ';') ?? ''},${transaction['billId'] ?? ''}\n';
      }

      // Create CSV content for bills
      String billsCsv = 'ID,Name,Amount,Frequency,Next Due Date,Autopay,Category ID,Notes,Last Paid Date,Is Paid,Link\n';
      for (final bill in bills) {
        billsCsv += '${bill['id']},${bill['name']?.replaceAll(',', ';') ?? ''},${bill['amount']},${bill['frequency']},${bill['nextDueDate']},${bill['autopay']},${bill['categoryId'] ?? ''},${bill['notes']?.replaceAll(',', ';') ?? ''},${bill['lastPaidDate'] ?? ''},${bill['isPaid']},${bill['link']?.replaceAll(',', ';') ?? ''}\n';
      }

      // Create CSV content for categories
      String categoriesCsv = 'ID,Name,Icon,Color\n';
      for (final category in categories) {
        categoriesCsv += '${category['id']},${category['name']?.replaceAll(',', ';') ?? ''},${category['icon'] ?? ''},${category['color'] ?? ''}\n';
      }

      // Get storage directory
      final directory = await _getStorageDirectory();
      
      if (directory == null) {
        _showErrorDialog('Could not access storage directory');
        return;
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      
      // Create files
      final transactionsFile = File('${directory.path}/transactions_$timestamp.csv');
      final billsFile = File('${directory.path}/bills_$timestamp.csv');
      final categoriesFile = File('${directory.path}/categories_$timestamp.csv');

      await transactionsFile.writeAsString(transactionsCsv);
      await billsFile.writeAsString(billsCsv);
      await categoriesFile.writeAsString(categoriesCsv);

      final locationMessage = _hasStoragePermission && Platform.isAndroid
          ? 'Downloads/ExpensesTracker/'
          : 'App Storage/ExpensesTracker/';

      _showExportSuccessDialog(locationMessage, directory.path, timestamp);

    } catch (e) {
      _showErrorDialog('Failed to export data: ${e.toString()}');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      setState(() {
        _hasStoragePermission = status.isGranted;
      });
      
      if (status.isGranted) {
        _showSuccessDialog('Storage permission granted! Exported files will now be saved to your Downloads folder.');
      } else {
        _showErrorDialog('Storage permission denied. Files will be saved to app storage only.');
      }
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

      _showSuccessDialog('All data cleared successfully!');
      
    } catch (e) {
      _showErrorDialog('Failed to clear data: ${e.toString()}');
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  void _showExportSuccessDialog(String location, String fullPath, String timestamp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Export Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your data has been exported successfully!'),
            SizedBox(height: 16),
            Text(
              'Location:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(location, style: TextStyle(fontSize: 12, color: Colors.blue)),
            SizedBox(height: 4),
            Text(fullPath, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            SizedBox(height: 12),
            Text(
              'Files created:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• transactions_$timestamp.csv'),
            Text('• bills_$timestamp.csv'),
            Text('• categories_$timestamp.csv'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Access files through your device\'s file manager app.',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
          // Storage Permission Card (Android only)
          if (Platform.isAndroid) ...[
            _buildSettingsCard(
              icon: _hasStoragePermission ? Icons.check_circle : Icons.folder,
              title: 'Storage Access',
              subtitle: _hasStoragePermission 
                  ? 'Storage permission granted - files save to Downloads' 
                  : 'Grant permission to save exports to Downloads folder',
              onTap: _hasStoragePermission ? null : () => _requestStoragePermission(),
              trailing: _hasStoragePermission 
                  ? Icon(Icons.check, color: Colors.green)
                  : null,
              textColor: _hasStoragePermission ? Colors.green : null,
            ),
            SizedBox(height: 8),
          ],
          _buildSettingsCard(
            icon: Icons.cloud_upload,
            title: 'Export Data',
            subtitle: _isExporting 
                ? 'Exporting data...' 
                : 'Export your transactions, bills, and categories to CSV',
            onTap: _isExporting ? null : () => _showExportDialog(),
            trailing: _isExporting 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
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
            subtitle: _isClearing 
                ? 'Clearing data...' 
                : 'Delete all transactions, bills, and categories',
            onTap: _isClearing ? null : () => _showClearDataDialog(context),
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
    VoidCallback? onTap,
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
            color: (textColor ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.1),
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
        trailing: trailing ?? (onTap != null ? Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .6),
        ) : null),
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
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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

  void _showExportDialog() {
    final String locationText = _hasStoragePermission && Platform.isAndroid
        ? 'Downloads/ExpensesTracker/ folder'
        : 'app storage folder';
        
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Data'),
        content: Text(
          'This will export all your transactions, bills, and categories to CSV files. Files will be saved to your $locationText.\n\nContinue with export?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData();
            },
            child: Text('Export'),
          ),
        ],
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'This will permanently delete ALL your data including:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• All transactions'),
            Text('• All bills and recurring payments'),
            Text('• All custom categories'),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Are you absolutely sure you want to continue?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Clear All Data'),
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