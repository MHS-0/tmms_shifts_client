import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';

part "preferences.g.dart";

// Constants related to preferences
// These keys and values are used to set and retrieve key-values using SharedPreferences
const themeModeKey = 'themeMode';
const lightThemeValue = 'light';
const darkThemeValue = 'dark';
const systemThemeValue = 'system';
const localeKey = 'locale';
const activeUserKey = 'activeUser';
const englishLocaleValue = 'english';
const persianLocaleValue = 'persian';

@JsonSerializable(explicitToJson: true)
class ActiveUser {
  ActiveUser({
    required this.username,
    required this.token,
    required this.isStaff,
    required this.expiry,
    required this.stations,
    required this.customStationSort,
    this.fullname,
  });

  String username;
  String? fullname;
  List<Station> stations;
  String token;
  bool isStaff;
  DateTime expiry;
  List<GetUsersCustomStationGroupResponseResultItem>? customStationSort;

  ActiveUser.fromLoginResponse(LoginResponse resp, GetProfileResponse profile)
    : username = profile.username,
      token = resp.token,
      isStaff = resp.user.isStaff,
      expiry = resp.expiry,
      fullname = profile.fullname,
      stations = profile.stations;

  ActiveUser copyWith({
    String? username,
    String? fullname,
    List<Station>? stations,
    String? token,
    bool? isStaff,
    DateTime? expiry,
    List<GetUsersCustomStationGroupResponseResultItem>? customStationSort,
  }) {
    return ActiveUser(
      username: username ?? this.username,
      token: token ?? this.token,
      isStaff: isStaff ?? this.isStaff,
      expiry: expiry ?? this.expiry,
      stations: stations ?? this.stations,
      customStationSort: customStationSort ?? this.customStationSort,
      fullname: fullname ?? this.fullname,
    );
  }

  /// Create a new instance with the class values updated from the latest
  /// GetProfile results.
  void updateFromNewGetProfile(GetProfileResponse resp) {
    username = resp.username;
    fullname = resp.fullname;
    isStaff = resp.isStaff;
    stations = resp.stations;
  }

  /// Create a new instance with the class values updated from the latest
  /// GetProfile results.
  void updateFromNewGetCustomStationGroup(
    GetUsersCustomStationGroupResponse resp,
  ) {
    customStationSort = resp.results;
  }

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
  static const persianLocale = Locale('fa');
  static const persianIRLocale = Locale('fa', 'IR');

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

    // Get the User's authentication information.
    final savedActiveUser = _sp.getString(activeUserKey);
    if (savedActiveUser != null) {
      final Map<String, dynamic> user = jsonDecode(savedActiveUser);
      final previousUser = ActiveUser.fromJson(user);
      final now = DateTime.now();
      if (previousUser.expiry.isBefore(now)) {
        await _sp.remove(activeUserKey);
      } else {
        _activeUser = previousUser;
      }
    } else {
      // Set it to null for testing purposes where we might call load()
      // multiple times with different preset SharedPreferences values.
      _activeUser = null;
    }
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

  /// Sets the user's details to SharedPreferences.
  Future<void> setActiveUser(ActiveUser user) async {
    await _sp.setString(activeUserKey, jsonEncode(user));
    _activeUser = user;
    notifyListeners();
  }

  /// Like setActiveUser, but doesn't call notifyListeners.
  /// Used for refreshing account details in GoRouter's redirect function
  /// when a page hasn't been loaded yet.
  Future<void> setActiveUserNoNotify(ActiveUser user) async {
    await _sp.setString(activeUserKey, jsonEncode(user));
    _activeUser = user;
  }

  /// Unsets the user's auth token from SharedPreferences.
  Future<void> unsetActiveUser() async {
    await _sp.remove(activeUserKey);
    _activeUser = null;
    notifyListeners();
  }

  /// Refresh anything that depends on Preferences.
  /// Used for now for buttons that refresh the page when an error occurs.
  void refreshRoute() {
    notifyListeners();
  }

  /// The factory that returns the singleton instance.
  factory Preferences.instance() => _preferences;
}
