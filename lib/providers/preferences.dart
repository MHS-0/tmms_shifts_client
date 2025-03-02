import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmms_shifts_client/consts.dart';

/// This provider class manages the SharedPreferences instance which holds the
/// user's theme and locale preferences and notifies the listeners of the changes
/// made in those values. The load method should be called and awaited before this
/// class can be used.
class Preferences extends ChangeNotifier {
  /// Private constructor to use when instantiating an instance inside the file.
  Preferences._privateConstructor();

  /// The singleton instance of this class
  static final Preferences _preferences = Preferences._privateConstructor();

  static const englishLocale = Locale('en');
  static const persianLocale = Locale('fa');

  /// The SharedPreferences instance
  late SharedPreferences _sp;

  /// The user's preferred theme mode
  late ThemeMode _themeMode;

  /// The user's preferred locale
  late Locale _locale;

  /// The user's stored authorization token
  String? _authToken;

  /// The user's preferred theme mode.
  ///
  /// Use the [setTheme] method to set a new ThemeMode.
  ThemeMode get themeMode => _themeMode;

  /// The user's preferred locale.
  ///
  /// Use the [setLocale] method to set a new Locale.
  Locale get locale => _locale;

  /// The user's stored authorization token
  String? get authToken => _authToken;

  /// Loads the user's preferences and sets the necessary instance variables. Should
  /// be called and awaited before the instance can be used.
  Future<void> load() async {
    _sp = await SharedPreferences.getInstance();

    // Get the User's preferred theme. Defaults to system theme.
    final savedThemeMode = _sp.getString(themeModeKey) ?? systemThemeValue;
    switch (savedThemeMode) {
      case lightThemeValue:
        _themeMode = ThemeMode.light;
        break;
      case darkThemeValue:
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    // Get the User's preferred locale. Defaults to English if system locale
    // isn't set to Persian.
    final savedLocale = _sp.getString(localeKey);
    switch (savedLocale) {
      case englishLocaleValue:
        _locale = englishLocale;
        break;
      case persianLocaleValue:
        _locale = persianLocale;
        break;
      default:
        if (!kIsWeb && Platform.localeName.contains('fa')) {
          _locale = persianLocale;
        } else {
          _locale = englishLocale;
        }
    }
  }

  /// Sets the user's preferred theme to [themeMode] and saves it to SharedPreferences.
  void setTheme(ThemeMode themeMode) {
    if (themeMode == _themeMode && _sp.getString(themeModeKey) != null) return;
    var themeValue = '';
    switch (themeMode) {
      case ThemeMode.light:
        themeValue = lightThemeValue;
        break;
      case ThemeMode.dark:
        themeValue = darkThemeValue;
        break;
      default:
        themeValue = systemThemeValue;
    }
    _sp.setString(themeModeKey, themeValue);
    _themeMode = themeMode;
    notifyListeners();
  }

  /// Sets the user's preferred localization to [locale] and saves it to SharedPreferences.
  void setLocale(Locale locale) {
    if (locale == _locale && _sp.getString(localeKey) != null) return;
    var localeValue = '';
    switch (locale.languageCode) {
      case 'fa':
        localeValue = persianLocaleValue;
        break;
      default:
        localeValue = englishLocaleValue;
    }
    _sp.setString(localeKey, localeValue);
    _locale = locale;
    notifyListeners();
  }

  /// Sets the user's auth token to [token] and saves it to SharedPreferences.
  void setAuthToken(String token) {
    if (token == _authToken && _sp.getString(authKey) != null) return;
    _sp.setString(authKey, token);
    _authToken = token;
    notifyListeners();
  }

  /// Unsets the user's auth token from SharedPreferences.
  void unsetAuthToken() {
    _sp.remove(authKey);
    _authToken = null;
    notifyListeners();
  }

  /// The factory that returns the singleton instance.
  factory Preferences.instance() => _preferences;
}
