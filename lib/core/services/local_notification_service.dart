import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification IDs for different notification types
/// Using unique IDs to allow independent management
abstract class NotificationIds {
  static const int streakReminder = 1;
  static const int dailyCheckIn = 2;
  static const int achievementBase = 100; // Achievements use 100+
}

/// Notification channel IDs (required for Android, informational for iOS)
abstract class NotificationChannels {
  static const String reminders = 'reminders';
  static const String achievements = 'achievements';
}

/// Local notification service for scheduling and showing notifications
///
/// Handles:
/// - Streak reminders (scheduled daily)
/// - Daily check-in prompts (scheduled daily)
/// - Achievement unlock alerts (immediate)
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService _instance = LocalNotificationService._();
  static LocalNotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the notification service
  /// Must be called before using any other methods
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('LocalNotificationService: already initialized');
      return;
    }

    debugPrint('LocalNotificationService: initializing...');

    // Initialize timezone database
    tz.initializeTimeZones();

    // Get local timezone - default to UTC if detection fails
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      // Map common abbreviations to proper timezone names
      final location = _getTimezoneLocation(timeZoneName);
      tz.setLocalLocation(location);
      debugPrint('LocalNotificationService: timezone set to ${location.name}');
    } catch (e) {
      debugPrint('LocalNotificationService: timezone detection failed, using UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    // iOS initialization settings
    // Request permissions later (during onboarding) for better UX
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      iOS: iosSettings,
      android: androidSettings,
    );

    // Initialize the plugin
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('LocalNotificationService: initialized successfully');
  }

  /// Get timezone location from timezone name
  tz.Location _getTimezoneLocation(String timeZoneName) {
    // Try direct lookup first
    try {
      return tz.getLocation(timeZoneName);
    } catch (_) {
      // Fall back to common mappings
      final mappings = {
        'AEST': 'Australia/Sydney',
        'AEDT': 'Australia/Sydney',
        'AWST': 'Australia/Perth',
        'EST': 'America/New_York',
        'EDT': 'America/New_York',
        'CST': 'America/Chicago',
        'CDT': 'America/Chicago',
        'MST': 'America/Denver',
        'MDT': 'America/Denver',
        'PST': 'America/Los_Angeles',
        'PDT': 'America/Los_Angeles',
        'GMT': 'Europe/London',
        'BST': 'Europe/London',
        'CET': 'Europe/Paris',
        'CEST': 'Europe/Paris',
      };

      final mapped = mappings[timeZoneName];
      if (mapped != null) {
        return tz.getLocation(mapped);
      }

      // Default to UTC
      return tz.UTC;
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('LocalNotificationService: notification tapped - ${response.payload}');
    // Navigation handling can be added here if needed
  }

  // ===========================================================================
  // Permission Management
  // ===========================================================================

  /// Request notification permissions from the user
  /// Returns true if permissions were granted
  Future<bool> requestPermission() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return true; // Permissions not needed on other platforms
    }

    debugPrint('LocalNotificationService: requesting permission...');

    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      debugPrint('LocalNotificationService: iOS permission result: $result');
      return result ?? false;
    }

    if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      debugPrint('LocalNotificationService: Android permission result: $result');
      return result ?? false;
    }

    return false;
  }

  /// Check if notification permissions are granted
  Future<bool> hasPermission() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return true;
    }

    // For iOS, check using the plugin
    if (Platform.isIOS) {
      // iOS doesn't have a direct check method in this plugin
      // We can only know after trying to request
      // Return true to indicate we should try scheduling
      return true;
    }

    if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return result ?? false;
    }

    return false;
  }

  // ===========================================================================
  // Notification Details
  // ===========================================================================

  /// Get iOS notification details
  DarwinNotificationDetails get _iosDetails => const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  /// Get Android notification details for reminders
  AndroidNotificationDetails get _androidReminderDetails => const AndroidNotificationDetails(
    NotificationChannels.reminders,
    'Reminders',
    channelDescription: 'Daily reminders and streak alerts',
    importance: Importance.high,
    priority: Priority.high,
  );

  /// Get Android notification details for achievements
  AndroidNotificationDetails get _androidAchievementDetails => const AndroidNotificationDetails(
    NotificationChannels.achievements,
    'Achievements',
    channelDescription: 'Achievement unlock notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  // ===========================================================================
  // Streak Reminder Notifications
  // ===========================================================================

  /// Schedule a daily streak reminder notification
  ///
  /// [currentStreak] - The user's current streak count
  /// [hour] - Hour to show notification (0-23), default 20 (8 PM)
  /// [minute] - Minute to show notification (0-59), default 0
  Future<void> scheduleStreakReminder({
    required int currentStreak,
    int hour = 20,
    int minute = 0,
  }) async {
    if (!_isInitialized) {
      debugPrint('LocalNotificationService: not initialized, skipping streak reminder');
      return;
    }

    // Cancel existing streak reminder first
    await cancelStreakReminder();

    final String title = currentStreak > 0
        ? "Don't lose your $currentStreak-day streak!"
        : 'Start your streak today!';

    final String body = currentStreak > 0
        ? 'Take a moment to chat with Apothy and keep your momentum going.'
        : 'Chat with Apothy to begin building your daily habit.';

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    debugPrint('LocalNotificationService: scheduling streak reminder for $scheduledTime');

    await _plugin.zonedSchedule(
      NotificationIds.streakReminder,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        iOS: _iosDetails,
        android: _androidReminderDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at this time
      payload: 'streak_reminder',
    );
  }

  /// Cancel the streak reminder notification
  Future<void> cancelStreakReminder() async {
    await _plugin.cancel(NotificationIds.streakReminder);
    debugPrint('LocalNotificationService: cancelled streak reminder');
  }

  // ===========================================================================
  // Daily Check-in Notifications
  // ===========================================================================

  /// Schedule a daily check-in prompt notification
  ///
  /// [hour] - Hour to show notification (0-23), default 9 (9 AM)
  /// [minute] - Minute to show notification (0-59), default 0
  Future<void> scheduleDailyCheckIn({
    int hour = 9,
    int minute = 0,
  }) async {
    if (!_isInitialized) {
      debugPrint('LocalNotificationService: not initialized, skipping daily check-in');
      return;
    }

    // Cancel existing daily check-in first
    await cancelDailyCheckIn();

    const String title = 'Your daily reflection awaits';
    const String body = 'Take a moment to connect with yourself. Apothy is here when you are ready.';

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    debugPrint('LocalNotificationService: scheduling daily check-in for $scheduledTime');

    await _plugin.zonedSchedule(
      NotificationIds.dailyCheckIn,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        iOS: _iosDetails,
        android: _androidReminderDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at this time
      payload: 'daily_checkin',
    );
  }

  /// Cancel the daily check-in notification
  Future<void> cancelDailyCheckIn() async {
    await _plugin.cancel(NotificationIds.dailyCheckIn);
    debugPrint('LocalNotificationService: cancelled daily check-in');
  }

  // ===========================================================================
  // Achievement Notifications
  // ===========================================================================

  /// Show an immediate notification for an unlocked achievement
  ///
  /// [achievementTitle] - The title of the achievement
  /// [achievementDescription] - The description of the achievement
  /// [achievementId] - Unique ID for the achievement (used to generate notification ID)
  Future<void> showAchievementUnlocked({
    required String achievementTitle,
    required String achievementDescription,
    required int achievementId,
  }) async {
    if (!_isInitialized) {
      debugPrint('LocalNotificationService: not initialized, skipping achievement notification');
      return;
    }

    final String title = 'Achievement Unlocked!';
    final String body = '$achievementTitle - $achievementDescription';

    debugPrint('LocalNotificationService: showing achievement notification for $achievementTitle');

    await _plugin.show(
      NotificationIds.achievementBase + achievementId,
      title,
      body,
      NotificationDetails(
        iOS: _iosDetails,
        android: _androidAchievementDetails,
      ),
      payload: 'achievement_$achievementId',
    );
  }

  // ===========================================================================
  // Utility Methods
  // ===========================================================================

  /// Get the next instance of a specific time
  /// If the time has already passed today, returns tomorrow at that time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    debugPrint('LocalNotificationService: cancelled all notifications');
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    debugPrint('LocalNotificationService: cancelled notification $id');
  }

  /// Get list of pending notification requests (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
