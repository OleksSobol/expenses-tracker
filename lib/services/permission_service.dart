// services/permission_service.dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  static const String _storagePermissionKey = 'storage_permission_requested';

  /// Check if storage permission has been requested before
  Future<bool> hasRequestedStoragePermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_storagePermissionKey) ?? false;
  }

  /// Mark that storage permission has been requested
  Future<void> markStoragePermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storagePermissionKey, true);
  }

  /// Check current storage permission status
  Future<bool> hasStoragePermission() async {
    if (Platform.isIOS) return true; // iOS doesn't need storage permission for app documents
    
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  /// Request storage permission with user-friendly explanation
  Future<PermissionStatus> requestStoragePermission() async {
    if (Platform.isIOS) return PermissionStatus.granted;
    
    final status = await Permission.storage.request();
    await markStoragePermissionRequested();
    return status;
  }

  /// Request storage permission on app startup if not done before
  Future<bool> requestStoragePermissionOnStartup() async {
    if (Platform.isIOS) return true;
    
    // Check if we've already asked
    final hasRequested = await hasRequestedStoragePermission();
    if (hasRequested) {
      // Just check current status
      return await hasStoragePermission();
    }

    // First time - request permission
    final status = await requestStoragePermission();
    return status.isGranted;
  }

  /// Get user-friendly permission status message
  String getPermissionStatusMessage(bool hasPermission) {
    if (Platform.isIOS) {
      return 'Files will be saved to app documents folder';
    }
    
    if (hasPermission) {
      return 'Files will be saved to Downloads/ExpensesTracker folder';
    } else {
      return 'Files will be saved to app storage folder';
    }
  }

  /// Legacy method for backward compatibility
  Future<bool> checkStoragePermission() async {
    return await hasStoragePermission();
  }

  /// Show permission rationale to user
  static String getPermissionRationale() {
    return 'This app would like to access your device storage to save exported data files (like transaction CSV files) to your Downloads folder, making them easier to find and share.\n\nIf you deny this permission, files will still be saved to the app\'s private storage folder, which you can access through a file manager.';
  }
}