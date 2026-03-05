// services/export_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'db_service.dart';

class ExportService {
  Future<Directory?> _getStorageDirectory(bool hasStoragePermission) async {
    if (Platform.isAndroid) {
      if (hasStoragePermission) {
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

  Future<void> exportAllData({
    required bool hasStoragePermission,
    required Function(String locationMessage, String fullPath, String timestamp) onSuccess,
    required Function(String message) onError,
  }) async {
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
      final directory = await _getStorageDirectory(hasStoragePermission);
      
      if (directory == null) {
        onError('Could not access storage directory');
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

      final locationMessage = hasStoragePermission && Platform.isAndroid
          ? 'Downloads/ExpensesTracker/'
          : 'App Storage/ExpensesTracker/';

      onSuccess(locationMessage, directory.path, timestamp);

    } catch (e) {
      onError('Failed to export data: ${e.toString()}');
    }
  }

  void showExportSuccessDialog({
    required BuildContext context,
    required String locationMessage,
    required String fullPath,
    required String timestamp,
  }) {
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
              Text(locationMessage, style: TextStyle(fontSize: 12, color: Colors.blue)),
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
  }