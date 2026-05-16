import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  User? _previousUser;

  Locale? get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  LocaleProvider() {
    _loadSettings();
    _listenToAuthChanges();
  }

  // --- Auth Listener Logic ---
  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // If we had a user and now we don't, it means a logout occurred
      if (_previousUser != null && user == null) {
        resetSettings();
      }
      _previousUser = user;
    });
  }

  // --- Language Logic ---
  void setLocale(Locale locale) {
    if (!['en', 'fr'].contains(locale.languageCode)) return;
    _locale = locale;
    _saveLocale(locale.languageCode);
    notifyListeners();
  }

  // --- Dark Mode Logic ---
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveTheme(mode.index);
    notifyListeners();
  }

  void toggleTheme(bool isOn) {
    setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
  }

  // Reset to light mode and English on logout
  void resetSettings() {
    _themeMode = ThemeMode.light;
    _locale = const Locale('en');
    _saveTheme(ThemeMode.light.index);
    _saveLocale('en');
    notifyListeners();
  }

  // --- Persistent Storage Logic ---
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }

    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    // Initialize the previous user state
    _previousUser = FirebaseAuth.instance.currentUser;

    notifyListeners();
  }

  Future<void> _saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  Future<void> _saveTheme(int themeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', themeIndex);
  }
}