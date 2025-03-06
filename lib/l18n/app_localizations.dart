import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa')
  ];

  /// The title of the app
  ///
  /// In en, this message translates to:
  /// **'tmms-shifts-client'**
  String get title;

  /// No description provided for @longTitle.
  ///
  /// In en, this message translates to:
  /// **'tmms data control panel'**
  String get longTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A client for tmms-shifts'**
  String get aboutDescription;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// No description provided for @cancelButtonText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonText;

  /// No description provided for @saveButtonText.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButtonText;

  /// No description provided for @okButtonText.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButtonText;

  /// No description provided for @searchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchFieldLabel;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme mode :'**
  String get themeDialogTitle;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language :'**
  String get languageDialogTitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @persian.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get persian;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @mainStuff.
  ///
  /// In en, this message translates to:
  /// **'Main stuff'**
  String get mainStuff;

  /// No description provided for @usernameTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameTextFieldHint;

  /// No description provided for @usernameTextFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameTextFieldLabel;

  /// No description provided for @passwordTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordTextFieldHint;

  /// No description provided for @passwordTextFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordTextFieldLabel;

  /// No description provided for @errorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'There was an error!'**
  String get errorDialogTitle;

  /// No description provided for @errorDialogDescBegin.
  ///
  /// In en, this message translates to:
  /// **'The error was:'**
  String get errorDialogDescBegin;

  /// No description provided for @errorDialogDescEnd.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get errorDialogDescEnd;

  /// No description provided for @fieldShouldBeFilled.
  ///
  /// In en, this message translates to:
  /// **'This field should be filled'**
  String get fieldShouldBeFilled;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @reportPressureAndTemp.
  ///
  /// In en, this message translates to:
  /// **'!'**
  String get reportPressureAndTemp;

  /// No description provided for @reportCorrectorNumbers.
  ///
  /// In en, this message translates to:
  /// **'!'**
  String get reportCorrectorNumbers;

  /// No description provided for @dataEntry.
  ///
  /// In en, this message translates to:
  /// **'!'**
  String get dataEntry;

  /// No description provided for @dataPressureAndTempEntry.
  ///
  /// In en, this message translates to:
  /// **'!'**
  String get dataPressureAndTempEntry;

  /// No description provided for @dataCorrectorNumberEntry.
  ///
  /// In en, this message translates to:
  /// **'!'**
  String get dataCorrectorNumberEntry;

  /// No description provided for @dataCorrectorReplacementEventEntry.
  ///
  /// In en, this message translates to:
  /// **'!'**
  String get dataCorrectorReplacementEventEntry;

  /// No description provided for @dataCounterEntry.
  ///
  /// In en, this message translates to:
  /// **'!'**
  String get dataCounterEntry;

  /// No description provided for @dataCounterReplacementEventEntry.
  ///
  /// In en, this message translates to:
  /// **'!'**
  String get dataCounterReplacementEventEntry;

  /// No description provided for @station.
  ///
  /// In en, this message translates to:
  /// **'station'**
  String get station;

  /// No description provided for @invalidUsernameOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid Username or password'**
  String get invalidUsernameOrPassword;

  /// No description provided for @chooseStation.
  ///
  /// In en, this message translates to:
  /// **'Choose a station'**
  String get chooseStation;

  /// No description provided for @finalll.
  ///
  /// In en, this message translates to:
  /// **'final'**
  String get finalll;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fa': return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
