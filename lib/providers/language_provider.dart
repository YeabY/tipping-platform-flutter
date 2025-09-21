import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  String _languageCode = 'en';

  // Getters
  Locale get locale => _locale;
  String get languageCode => _languageCode;
  String get languageName {
    switch (_languageCode) {
      case 'en':
        return 'English';
      case 'am':
        return 'አማርኛ';
      default:
        return 'English';
    }
  }

  // Initialize language from preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.languageKey) ?? 'en';
    await setLanguage(languageCode);
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    _languageCode = languageCode;
    
    switch (languageCode) {
      case 'en':
        _locale = const Locale('en', 'US');
        break;
      case 'am':
        _locale = const Locale('am', 'ET');
        break;
      default:
        _locale = const Locale('en', 'US');
        _languageCode = 'en';
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, _languageCode);
    
    notifyListeners();
  }

  // Toggle between English and Amharic
  Future<void> toggleLanguage() async {
    if (_languageCode == 'en') {
      await setLanguage('am');
    } else {
      await setLanguage('en');
    }
  }

  // Set English
  Future<void> setEnglish() async {
    await setLanguage('en');
  }

  // Set Amharic
  Future<void> setAmharic() async {
    await setLanguage('am');
  }

  // Check if current language is English
  bool get isEnglish => _languageCode == 'en';

  // Check if current language is Amharic
  bool get isAmharic => _languageCode == 'am';

  // Get supported languages
  List<Map<String, String>> get supportedLanguages => [
    {'code': 'en', 'name': 'English'},
    {'code': 'am', 'name': 'አማርኛ'},
  ];
}
