// widgets/permission_dialog.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../services/permission_service.dart';

class PermissionDialog extends StatelessWidget {
  final VoidCallback? onPermissionResult;

  const PermissionDialog({
    super.key,
    this.onPermissionResult,
  });

  static Future<bool?> show(BuildContext context) async {
    if (Platform.isIOS) return true; // iOS doesn't need this dialog
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (context) => PermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.folder_open,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Storage Access',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Expenses Tracker!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Text(PermissionService.getPermissionRationale()),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'With permission: Files saved to Downloads/ExpensesTracker',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Without permission: Files saved to app storage (still accessible)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            // User chose not to grant permission
            final permissionService = PermissionService();
            await permissionService.markStoragePermissionRequested();
            Navigator.of(context).pop(false);
            if (onPermissionResult != null) onPermissionResult!();
          },
          child: Text(
            'Not Now',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            // Request permission
            final permissionService = PermissionService();
            final status = await permissionService.requestStoragePermission();
            final granted = status.isGranted;
            
            Navigator.of(context).pop(granted);
            if (onPermissionResult != null) onPermissionResult!();
          },
          child: Text('Allow Access'),
        ),
      ],
    );
  }
}

class PermissionResultDialog extends StatelessWidget {
  final bool granted;
  
  const PermissionResultDialog({
    super.key,
    required this.granted,
  });

  static void show(BuildContext context, bool granted) {
    showDialog(
      context: context,
      builder: (context) => PermissionResultDialog(granted: granted),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.info,
            color: granted ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 8),
          Text(granted ? 'Permission Granted' : 'Permission Denied'),
        ],
      ),
      content: Text(
        granted
            ? 'Great! Your exported files will be saved to the Downloads/ExpensesTracker folder for easy access.'
            : 'No problem! Your exported files will be saved to the app storage folder. You can still access them through your file manager app.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Got it'),
        ),
      ],
    );
  }
}