import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/tip.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  List<Tip> _recentTips = [];

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  List<Tip> get recentTips => _recentTips;
  int get unreadTipsCount => _recentTips.where((tip) => tip.isCompleted).length;

  // Initialize notification settings from preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(AppConstants.notificationsEnabledKey) ?? true;
    _pushNotificationsEnabled = prefs.getBool('push_notifications_enabled') ?? true;
    _emailNotificationsEnabled = prefs.getBool('email_notifications_enabled') ?? true;
    notifyListeners();
  }

  // Toggle all notifications
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.notificationsEnabledKey, enabled);
    notifyListeners();
  }

  // Toggle push notifications
  Future<void> togglePushNotifications(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications_enabled', enabled);
    notifyListeners();
  }

  // Toggle email notifications
  Future<void> toggleEmailNotifications(bool enabled) async {
    _emailNotificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications_enabled', enabled);
    notifyListeners();
  }

  // Add new tip notification
  void addTipNotification(Tip tip) {
    _recentTips.insert(0, tip);
    // Keep only last 50 tips
    if (_recentTips.length > 50) {
      _recentTips = _recentTips.take(50).toList();
    }
    notifyListeners();
  }

  // Mark tip as read
  void markTipAsRead(String tipId) {
    final index = _recentTips.indexWhere((tip) => tip.id == tipId);
    if (index != -1) {
      // You could add a 'read' property to the Tip model if needed
      notifyListeners();
    }
  }

  // Clear all notifications
  void clearAllNotifications() {
    _recentTips.clear();
    notifyListeners();
  }

  // Get notification settings
  Map<String, bool> get notificationSettings => {
    'notifications': _notificationsEnabled,
    'push': _pushNotificationsEnabled,
    'email': _emailNotificationsEnabled,
  };

  // Update all notification settings
  Future<void> updateNotificationSettings({
    bool? notifications,
    bool? push,
    bool? email,
  }) async {
    if (notifications != null) {
      await toggleNotifications(notifications);
    }
    if (push != null) {
      await togglePushNotifications(push);
    }
    if (email != null) {
      await toggleEmailNotifications(email);
    }
  }
}
