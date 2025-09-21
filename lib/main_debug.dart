import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_constants.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Starting app initialization...');
  
  try {
    print('Initializing theme provider...');
    // Initialize theme provider
    final themeProvider = ThemeProvider();
    await themeProvider.initialize();
    print('Theme provider initialized');
    
    print('Initializing language provider...');
    // Initialize language provider
    final languageProvider = LanguageProvider();
    await languageProvider.initialize();
    print('Language provider initialized');
    
    print('Initializing auth provider...');
    // Initialize auth provider
    final authProvider = AuthProvider();
    await authProvider.initialize();
    print('Auth provider initialized');
    
    print('All providers initialized successfully');
  } catch (e) {
    print('Initialization error: $e');
  }
  
  print('Starting app...');
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
            
            // Routing Configuration
            initialRoute: AppRoutes.splash,
            onGenerateRoute: _generateRoute,
          );
        },
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const DebugSplashScreen(),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const SimpleHomeScreen(),
        );
    }
  }
}

class DebugSplashScreen extends StatefulWidget {
  const DebugSplashScreen({super.key});

  @override
  State<DebugSplashScreen> createState() => _DebugSplashScreenState();
}

class _DebugSplashScreenState extends State<DebugSplashScreen> {
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _status = 'Loading theme...';
    });
    
    try {
      await context.read<ThemeProvider>().initialize();
      setState(() {
        _status = 'Loading language...';
      });
    } catch (e) {
      setState(() {
        _status = 'Theme error: $e';
      });
      return;
    }

    try {
      await context.read<LanguageProvider>().initialize();
      setState(() {
        _status = 'Loading auth...';
      });
    } catch (e) {
      setState(() {
        _status = 'Language error: $e';
      });
      return;
    }

    try {
      await context.read<AuthProvider>().initialize();
      setState(() {
        _status = 'Complete!';
      });
    } catch (e) {
      setState(() {
        _status = 'Auth error: $e';
      });
      return;
    }

    // Wait a bit then navigate
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 60,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Support your favorite creators',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _status,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 80,
              color: Colors.indigo,
            ),
            SizedBox(height: 24),
            Text(
              'Welcome to Tipping Platform!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'The app is working correctly!',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
