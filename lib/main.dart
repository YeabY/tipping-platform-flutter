import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants/app_constants.dart';
import 'models/user.dart';
import 'models/tip.dart';
import 'models/payment.dart';
import 'models/analytics.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notification_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/tipping/tip_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'utils/app_theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register Hive adapters (only if they exist)
    try {
      Hive.registerAdapter(UserAdapter());
      Hive.registerAdapter(TipAdapter());
      Hive.registerAdapter(TipStatusAdapter());
      Hive.registerAdapter(CurrencyAdapter());
      Hive.registerAdapter(PaymentAdapter());
      Hive.registerAdapter(PaymentMethodAdapter());
      Hive.registerAdapter(PaymentStatusAdapter());
      Hive.registerAdapter(CreatorAnalyticsAdapter());
      Hive.registerAdapter(TipFrequencyAdapter());
      Hive.registerAdapter(TopTipperAdapter());
    } catch (e) {
      print('Hive adapters not found - continuing without local storage: $e');
    }
    
    // Initialize notification service
    try {
      await NotificationService.initialize();
    } catch (e) {
      print('Notification service initialization failed: $e');
    }
  } catch (e) {
    print('Initialization error: $e');
  }
  
  runApp(const TippingPlatformApp());
}

class TippingPlatformApp extends StatelessWidget {
  const TippingPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer3<ThemeProvider, LanguageProvider, AuthProvider>(
        builder: (context, themeProvider, languageProvider, authProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            
            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Localization Configuration
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('am', 'ET'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // Routing Configuration
            initialRoute: AppRoutes.splash,
            onGenerateRoute: _generateRoute,
            
            // Builder for global error handling
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      
      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
          settings: settings,
        );
      
      case AppRoutes.tipPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TipScreen(
            creator: args?['creator'],
            tipperName: args?['tipperName'],
          ),
          settings: settings,
        );
      
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      
      // Add more routes as we create the screens
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}