import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';

part "preferences.g.dart";

@JsonSerializable()
class ActiveUser {
  ActiveUser({
    required this.username,
    required this.password,
    required this.token,
    required this.isStaff,
    required this.expiry,
    required this.stations,
    this.fullname,
  });

  final String username;
  final String password;
  final String? fullname;
  final List<Station> stations;
  final String token;
  final bool isStaff;
  final DateTime expiry;

  ActiveUser.fromLoginResponse(
    LoginResponse resp,
    GetProfileResponse profile,
    this.password,
  ) : username = profile.username,
      token = resp.token,
      isStaff = resp.user.isStaff,
      expiry = resp.expiry,
      fullname = profile.fullname,
      stations = profile.stations ?? [];

  factory ActiveUser.fromJson(Map<String, dynamic> json) =>
      _$ActiveUserFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveUserToJson(this);
}

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
  static const persianLocale = Locale('fa', 'IR');

  /// The SharedPreferences instance
  late SharedPreferences _sp;

  /// The user's preferred theme mode
  late ThemeMode _themeMode;

  /// The user's preferred locale
  late Locale _locale;

  /// The user's stored authorization token
  ActiveUser? _activeUser;

  /// The user's preferred theme mode.
  ///
  /// Use the [setTheme] method to set a new ThemeMode.
  ThemeMode get themeMode => _themeMode;

  /// The user's preferred locale.
  ///
  /// Use the [setLocale] method to set a new Locale.
  Locale get locale => _locale;

  /// The user's stored authorization token
  ActiveUser? get activeUser => _activeUser;

  /// Loads the user's preferences and sets the necessary instance variables. Should
  /// be called and awaited before the instance can be used.
  Future<void> load() async {
    _sp = await SharedPreferences.getInstance();

    // Get the User's preferred theme. Defaults to system theme.
    final savedThemeMode = _sp.getString(themeModeKey) ?? lightThemeValue;
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

    // Get the User's preferred locale. Defaults to Persian.
    final savedLocale = _sp.getString(localeKey);
    switch (savedLocale) {
      case englishLocaleValue:
        _locale = englishLocale;
        break;
      case persianLocaleValue:
        _locale = persianLocale;
        break;
      default:
        _locale = persianLocale;
    }

    // FIX: Replace with actual code!!!
    _activeUser = ActiveUser(
      username: "admin",
      password: "asd123!@#",
      token: "asdasdasdaasd",
      isStaff: true,
      expiry: DateTime.now().add(Duration(days: 365)),
      fullname: "Mammad",
      stations: [
        Station(
          code: "123",
          rans: [
            Ran(code: 1, sequenceNumber: 1, station: 123),
            Ran(code: 2, sequenceNumber: 2, station: 123),
          ],
          typeName: "CGS",
          title: "مهدی شهر",
          district: "مهدی شهر",
          area: "Semnan",
          capacity: 1234,
          type: 1,
          activity: 1,
        ),
        Station(
          code: "142",
          rans: [
            Ran(code: 4, sequenceNumber: 1, station: 142),
            Ran(code: 5, sequenceNumber: 2, station: 142),
          ],
          typeName: "CGS",
          title: "سمنان",
          district: "سمنان",
          area: "Semnan",
          capacity: 1234,
          type: 1,
          activity: 2,
        ),
      ],
    );

    // final savedActiveUser = _sp.getString(activeUserKey);
    // if (savedActiveUser != null) {
    //   final Map<String, dynamic> user = jsonDecode(savedActiveUser);
    //   final previousUser = ActiveUser.fromJson(user);
    //   final now = DateTime.now();
    //   if (previousUser.expiry.isAfter(now)) {
    //     _sp.remove(activeUserKey);
    //   } else {
    //     _activeUser = previousUser;
    //   }
    // }
  }

  /// Sets the user's preferred theme to [themeMode] and saves it to SharedPreferences.
  void setTheme(ThemeMode themeMode) {
    if (themeMode == _themeMode && _sp.getString(themeModeKey) != null) {
      notifyListeners();
      return;
    }

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
    if (locale == _locale && _sp.getString(localeKey) != null) {
      notifyListeners();
      return;
    }

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
  void setActiveUser(
    LoginResponse resp,
    GetProfileResponse profile,
    String password,
  ) {
    final user = ActiveUser.fromLoginResponse(resp, profile, password);
    _sp.setString(activeUserKey, jsonEncode(user.toJson));
    _activeUser = user;
    notifyListeners();
  }

  /// Unsets the user's auth token from SharedPreferences.
  void unsetActiveUser() {
    _sp.remove(activeUserKey);
    _activeUser = null;
    notifyListeners();
  }

  /// The factory that returns the singleton instance.
  factory Preferences.instance() => _preferences;
}
