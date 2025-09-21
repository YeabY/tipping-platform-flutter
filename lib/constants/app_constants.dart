class AppConstants {
  // App Information
  static const String appName = 'Tipping Platform';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.tippingplatform.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Payment Gateway Configuration
  static const String stripePublishableKey = 'pk_test_your_stripe_key_here';
  static const String stripeSecretKey = 'sk_test_your_stripe_secret_here';
  static const double platformFeePercentage = 2.9; // 2.9% platform fee
  
  // Supported Currencies
  static const List<String> supportedCurrencies = ['USD', 'ETB'];
  static const String defaultCurrency = 'USD';
  
  // Tip Amount Presets (in USD)
  static const List<double> tipPresets = [1.00, 5.00, 10.00, 25.00, 50.00, 100.00];
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxBioLength = 500;
  static const int maxMessageLength = 500;
  static const int maxDisplayNameLength = 50;
  
  // File Upload Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  
  // Cache Keys
  static const String userCacheKey = 'current_user';
  static const String authTokenKey = 'auth_token';
  static const String analyticsCacheKey = 'creator_analytics';
  static const String tipsCacheKey = 'creator_tips';
  
  // Notification Channels
  static const String tipNotificationChannelId = 'tip_notifications';
  static const String tipNotificationChannelName = 'Tip Notifications';
  static const String tipNotificationChannelDescription = 'Notifications for new tips received';
  
  // Deep Link URLs
  static const String deepLinkBaseUrl = 'https://tippingplatform.com';
  static const String tipPathPrefix = '/tip/';
  static const String profilePathPrefix = '/profile/';
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String serverErrorMessage = 'Server error. Please try again later';
  static const String unauthorizedErrorMessage = 'Please log in to continue';
  static const String paymentErrorMessage = 'Payment failed. Please try again';
  
  // Success Messages
  static const String tipSentSuccessMessage = 'Tip sent successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully';
  static const String withdrawalRequestMessage = 'Withdrawal request submitted';
  
  // Local Storage Keys
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Rate Limiting
  static const int maxTipsPerHour = 10;
  static const int maxLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 15);
}

class CurrencySymbols {
  static const String usd = '\$';
  static const String etb = 'ብር';
  
  static String getSymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return usd;
      case 'ETB':
        return etb;
      default:
        return usd;
    }
  }
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String tipPage = '/tip';
  static const String dashboard = '/dashboard';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String paymentMethods = '/payment-methods';
  static const String withdrawal = '/withdrawal';
  static const String tipHistory = '/tip-history';
  static const String creatorProfile = '/creator-profile';
}
