// services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // You can add navigation logic here if needed
    print('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    
    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  /// Get notification preference for advance days
  Future<int> getNotificationDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('notification_days') ?? 1; // Default: 1 day before
  }

  /// Set notification preference for advance days
  Future<void> setNotificationDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_days', days);
  }

  /// Schedule a notification for a bill
  Future<void> scheduleBillNotification({
    required int billId,
    required String billName,
    required double amount,
    required DateTime dueDate,
  }) async {
    if (!await areNotificationsEnabled()) return;

    final notificationDays = await getNotificationDays();
    final notificationDate = dueDate.subtract(Duration(days: notificationDays));
    
    // Don't schedule if the notification date is in the past
    if (notificationDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'bill_reminders',
      'Bill Reminders',
      channelDescription: 'Notifications for upcoming bill due dates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'bill_reminder',
      interruptionLevel: InterruptionLevel.active,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final formattedAmount = amount.toStringAsFixed(2);
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    
    String title;
    String body;
    
    if (daysUntilDue == 1) {
      title = 'Bill Due Tomorrow';
      body = '$billName (\$$formattedAmount) is due tomorrow';
    } else if (daysUntilDue == 0) {
      title = 'Bill Due Today';
      body = '$billName (\$$formattedAmount) is due today';
    } else {
      title = 'Upcoming Bill';
      body = '$billName (\$$formattedAmount) is due in $daysUntilDue days';
    }

    await _notifications.zonedSchedule(
      billId, // Use bill ID as notification ID
      title,
      body,
      tz.TZDateTime.from(notificationDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'bill_$billId',
    );
  }

  /// Cancel a specific bill notification
  Future<void> cancelBillNotification(int billId) async {
    await _notifications.cancel(billId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Reschedule all bill notifications (call this when bills are updated)
  Future<void> rescheduleAllBillNotifications(List<Map<String, dynamic>> bills) async {
    // Cancel all existing notifications first
    await cancelAllNotifications();
    
    if (!await areNotificationsEnabled()) return;

    // Schedule notifications for all active bills
    for (final bill in bills) {
      if (bill['isPaid'] == 1) continue; // Skip paid bills

      final dueDate = DateTime.parse(bill['nextDueDate']);
      await scheduleBillNotification(
        billId: bill['id'],
        billName: bill['name'],
        amount: bill['amount'],
        dueDate: dueDate,
      );
    }
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Show immediate test notification
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test',
      'Test Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999, // Test notification ID
      'Test Notification',
      'This is a test notification from Expenses Tracker',
      notificationDetails,
    );
  }
}