import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _initialized = false;
  bool get initialized => _initialized;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get theme =>
      _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  // ------------------------------------------------------------
  // LOAD SAVED THEME FROM SECURE STORAGE
  // ------------------------------------------------------------
  Future<void> _loadTheme() async {
    final saved = await _storage.read(key: "app_theme");

    if (saved != null) {
      _isDarkMode = (saved == "dark");
    } else {
      _isDarkMode = false; // default
    }

    _initialized = true;
    notifyListeners();
  }

  // ------------------------------------------------------------
  // TOGGLE THEME + SAVE TO SECURE STORAGE
  // ------------------------------------------------------------
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.write(
        key: "app_theme", value: _isDarkMode ? "dark" : "light");

    notifyListeners();
  }
}
