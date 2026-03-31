import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// A singleton service to manage local notifications in a Flutter app.
class NotificationsService {
  // Singleton instance
  static final NotificationsService _instance = NotificationsService._internal();

  /// Factory constructor to return the singleton instance
  factory NotificationsService() => _instance;

  /// Private internal constructor
  NotificationsService._internal();

  /// The Flutter Local Notifications plugin instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notifications plugin and the timezone package.
  /// 
  /// This must be called before showing or scheduling notifications.
  Future<void> init() async {
    // Android-specific initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // General initialization settings
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    // Initialize timezone database
    tz.initializeTimeZones();

    // Set the local timezone (change 'Europe/Rome' to your local timezone)
    tz.setLocalLocation(tz.getLocation('Europe/Rome'));

    // Initialize the notifications plugin
    await flutterLocalNotificationsPlugin.initialize(
      settings: settings
    );
  }

  /// Shows an immediate notification on the device.
  ///
  /// [title] is the notification title.
  /// [body] is the content text of the notification.
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // Android notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id', // ID of the notification channel
      'channel_name', // Visible name of the channel
      channelDescription: 'Channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Platform-specific details
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    // Show the notification immediately
    await flutterLocalNotificationsPlugin.show(
      id: 0, // Notification ID
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  /// Schedules a notification to appear at a specific [scheduledTime].
  ///
  /// [title] is the notification title.
  /// [body] is the notification content text.
  /// [scheduledTime] is the DateTime when the notification should appear.
  /// The [scheduledTime] is converted to the correct local timezone automatically.
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Convert DateTime to TZDateTime in local timezone
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // Android notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'Channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Platform-specific details
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1, // Notification ID
      title: title,
      body: body,
      scheduledDate: tzScheduledTime, // Must be TZDateTime
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}