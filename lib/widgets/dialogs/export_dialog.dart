// widgets/dialogs/export_dialog.dart
import 'package:flutter/material.dart';
import 'dart:io';

class ExportDialog {
  static void show({
    required BuildContext context,
    required bool hasStoragePermission,
    required VoidCallback onConfirm,
  }) {
    final String locationText = hasStoragePermission && Platform.isAndroid
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
              onConfirm();
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }
}