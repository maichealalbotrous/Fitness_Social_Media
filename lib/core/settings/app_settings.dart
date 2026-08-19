import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static final instance = AppSettings._();
  AppSettings._();
  static const _themeKey = 'app_theme_mode';
  static const _languageKey = 'app_language';
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getString(_themeKey) == 'light' ? ThemeMode.light : ThemeMode.dark;
    _locale = (prefs.getString(_languageKey) ?? 'en') == 'ar' ? const Locale('ar') : const Locale('en');
    notifyListeners();
  }
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }
  Future<void> setLanguage(String code) async {
    _locale = code == 'ar' ? const Locale('ar') : const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _locale.languageCode);
    notifyListeners();
  }
}
