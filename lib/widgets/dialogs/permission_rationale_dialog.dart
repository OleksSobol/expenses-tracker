// widgets/dialogs/permission_rationale_dialog.dart
import 'package:flutter/material.dart';
import '../../services/permission_service.dart';

class PermissionRationaleDialog {
  static void show({
    required BuildContext context,
    required VoidCallback onContinue,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.folder, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8),
            Text('Storage Access'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why does this app need storage access?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(PermissionService.getPermissionRationale()),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can always change this permission later in your device settings.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onCancel();
              },
              child: Text('Not Now'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}