import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_constants.dart';
import '../models/tip.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  // Create notification channel for Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      AppConstants.tipNotificationChannelId,
      AppConstants.tipNotificationChannelName,
      description: AppConstants.tipNotificationChannelDescription,
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap based on payload
    final payload = response.payload;
    if (payload != null) {
      // Navigate to appropriate screen based on payload
      // This will be handled by the app's routing system
    }
  }

  // Show tip received notification
  static Future<void> showTipReceivedNotification(Tip tip) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      AppConstants.tipNotificationChannelId,
      AppConstants.tipNotificationChannelName,
      channelDescription: AppConstants.tipNotificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      tip.id.hashCode,
      'New Tip Received!',
      'You received ${tip.formattedAmount} from ${tip.tipperName}',
      notificationDetails,
      payload: 'tip:${tip.id}',
    );
  }

  // Show withdrawal processed notification
  static Future<void> showWithdrawalProcessedNotification(
    double amount,
    String currency,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      AppConstants.tipNotificationChannelId,
      AppConstants.tipNotificationChannelName,
      channelDescription: AppConstants.tipNotificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final currencySymbol = currency.toUpperCase() == 'USD' ? '\$' : 'ብር';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch,
      'Withdrawal Processed',
      'Your withdrawal of $currencySymbol${amount.toStringAsFixed(2)} has been processed',
      notificationDetails,
      payload: 'withdrawal:processed',
    );
  }

  // Show withdrawal failed notification
  static Future<void> showWithdrawalFailedNotification(
    double amount,
    String currency,
    String reason,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      AppConstants.tipNotificationChannelId,
      AppConstants.tipNotificationChannelName,
      channelDescription: AppConstants.tipNotificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final currencySymbol = currency.toUpperCase() == 'USD' ? '\$' : 'ብር';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch,
      'Withdrawal Failed',
      'Your withdrawal of $currencySymbol${amount.toStringAsFixed(2)} failed: $reason',
      notificationDetails,
      payload: 'withdrawal:failed',
    );
  }

  // Show general notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      AppConstants.tipNotificationChannelId,
      AppConstants.tipNotificationChannelName,
      channelDescription: AppConstants.tipNotificationChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return true; // Assume enabled for iOS
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission() ?? false;
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      return await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }

    return false;
  }
}
