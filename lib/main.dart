import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/sort_provider.dart';
import 'package:tmms_shifts_client/routes/corrector_replacement_events.dart';
import 'package:tmms_shifts_client/routes/counter_corrector_reports.dart';
import 'package:tmms_shifts_client/routes/counter_replacement_events.dart';
import 'package:tmms_shifts_client/routes/login.dart';
import 'package:tmms_shifts_client/routes/monitoring_full_report_route.dart';
import 'package:tmms_shifts_client/routes/page_not_found_route.dart';
import 'package:tmms_shifts_client/routes/pressure_and_temp_reports_route.dart';
import 'package:tmms_shifts_client/theme.dart';
import 'l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print("${record.level.name} ${record.time}: ${record.message}");
  });

  await Preferences.instance().load();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: Preferences.instance())],
      child: const App(),
    ),
  );
}

const monitoringFullReportPath = "/";
const pressureAndTempReportsPath = "/pressure-and-temp-reports";
const counterCorrectorReportsPath = '/counter-corrector-reports';
const correctorReplacementEventsPath = '/corrector-replacement-events';
const counterReplacementEventsPath = '/counter-replacement-events';
const pageNotFoundPath = '/404';
const loginPath = '/login';

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: monitoringFullReportPath,
      name: MonitoringFullReportRoute.routingName,
      pageBuilder: (_, state) {
        final queries = state.uri.queryParameters;
        final stationCodes = queries[stationCodesKey];
        final fromDate = queries[fromDateKey];
        final toDate = queries[toDateKey];
        final sortBy = queries[sortByKey];

        return Helpers.materialPageWithMultiProviders(
          state,
          MonitoringFullReportRoute(
            stationCodes: stationCodes,
            fromDate: fromDate,
            toDate: toDate,
            sortBy: sortBy,
          ),
          MonitoringFullReportRoute.routingName,
        );
      },
    ),
    GoRoute(
      path: pageNotFoundPath,
      name: PageNotFoundRoute.routingName,
      pageBuilder: (_, __) {
        return const MaterialPage(child: PageNotFoundRoute());
      },
    ),
    GoRoute(
      path: loginPath,
      name: LoginRoute.routingName,
      pageBuilder: (_, __) {
        return const MaterialPage(child: LoginRoute());
      },
    ),
    GoRoute(
      path: correctorReplacementEventsPath,
      name: CorrectorReplacementEventsRoute.routingName,
      pageBuilder: (_, state) {
        final queries = state.uri.queryParameters;
        final stationCodes = queries[stationCodesKey];
        final fromDate = queries[fromDateKey];
        final toDate = queries[toDateKey];
        final sortBy = queries[sortByKey];

        return Helpers.materialPageWithMultiProviders(
          state,
          CorrectorReplacementEventsRoute(
            stationCodes: stationCodes,
            fromDate: fromDate,
            toDate: toDate,
            sortBy: sortBy,
          ),
          CorrectorReplacementEventsRoute.routingName,
        );
      },
    ),
    GoRoute(
      path: counterReplacementEventsPath,
      name: CounterReplacementEventsRoute.routingName,
      pageBuilder: (_, state) {
        final queries = state.uri.queryParameters;
        final stationCodes = queries[stationCodesKey];
        final fromDate = queries[fromDateKey];
        final toDate = queries[toDateKey];
        final sortBy = queries[sortByKey];

        return Helpers.materialPageWithMultiProviders(
          state,
          CounterReplacementEventsRoute(
            stationCodes: stationCodes,
            fromDate: fromDate,
            toDate: toDate,
            sortBy: sortBy,
          ),
          CounterReplacementEventsRoute.routingName,
        );
      },
    ),
    GoRoute(
      path: counterCorrectorReportsPath,
      name: CounterCorrectorReportsRoute.routingName,
      pageBuilder: (_, state) {
        final queries = state.uri.queryParameters;
        final stationCodes = queries[stationCodesKey];
        final fromDate = queries[fromDateKey];
        final toDate = queries[toDateKey];
        final sortBy = queries[sortByKey];

        return Helpers.materialPageWithMultiProviders(
          state,
          CounterCorrectorReportsRoute(
            stationCodes: stationCodes,
            fromDate: fromDate,
            toDate: toDate,
            sortBy: sortBy,
          ),
          CounterCorrectorReportsRoute.routingName,
        );
      },
    ),
    GoRoute(
      path: pressureAndTempReportsPath,
      name: PressureAndTempReportsRoute.routingName,
      pageBuilder: (_, state) {
        final queries = state.uri.queryParameters;
        final stationCodes = queries[stationCodesKey];
        final fromDate = queries[fromDateKey];
        final toDate = queries[toDateKey];
        final sortBy = queries[sortByKey];

        return Helpers.materialPageWithMultiProviders(
          state,
          PressureAndTempReportsRoute(
            stationCodes: stationCodes,
            fromDate: fromDate,
            toDate: toDate,
            sortBy: sortBy,
          ),
          PressureAndTempReportsRoute.routingName,
        );
      },
    ),
  ],
  redirect: (context, state) async {
    final user = context.read<Preferences>().activeUser;
    final loggedIn = user != null;

    final instance = NetworkInterface.instance();

    final statePath = state.uri.path;
    final queryParameters = state.uri.queryParameters.map(
      (k, v) => MapEntry(k, v),
    );

    /// Redirect to login if needed.
    if (!loggedIn) {
      return "/login";
    }
    // Logout if session is expired. For example if the auth token has expired.
    final result = await instance.getProfile(user.token);
    if (result == null) {
      sharedLogger.info("User isn't logged in. Logging out...");
      await Preferences.instance().unsetActiveUser();
      return "/login";
    }

    /// Redirect from login to home if already logged in.
    if (loggedIn && state.uri.path.contains("login")) {
      return "/";
    }

    /// Some paths require some queries such as from_date and to_date.
    /// If routed without those queries, add those queries for the user and redirect.
    final queryRequiredPaths = [
      pressureAndTempReportsPath,
      monitoringFullReportPath,
      counterCorrectorReportsPath,
      counterReplacementEventsPath,
      correctorReplacementEventsPath,
    ];
    if (queryRequiredPaths.contains(statePath)) {
      if (!queryParameters.containsKey(fromDateKey)) {
        queryParameters[fromDateKey] = Helpers.jalaliToDashDate(
          Jalali.now().addDays(-1),
        );
      }

      if (!queryParameters.containsKey(toDateKey)) {
        queryParameters[toDateKey] = Helpers.jalaliToDashDate(Jalali.now());
      }

      if (!queryParameters.containsKey(sortByKey)) {
        queryParameters[sortByKey] = byDateDescQueryValue;
      }

      return state.uri.replace(queryParameters: queryParameters).toString();
    }

    return null;
  },
  errorPageBuilder: (_, __) {
    return const MaterialPage(child: PageNotFoundRoute());
  },
);

/// This class defines the general outline of the app, its themes, locales, routes
/// and other settings that are related to the class containing the [MaterialApp] instance
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Preferences>(
      builder: (_, value, _) {
        return AnimatedBuilder(
          animation: value,
          builder: (context, _) {
            return MaterialApp.router(
              // Set the font size scaling throughout the app so that the texts are bigger and
              // read easier.
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(1.25),
                  ),
                  child: child!,
                );
              },
              debugShowCheckedModeBanner: false,
              restorationScopeId: 'tmms-shifts-client',
              // Run the program with the Persian locale regardless
              // of the set Locale on the system.
              // Other locales such as English aren't fully implemented for the app
              // and frankly they aren't needed either.
              locale: Preferences.persianLocale,
              onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
              // The below two lines are needed for localizations. They set the supported
              // languages for this app and make the AppLocalizations.of callback available.
              localizationsDelegates: [
                PersianMaterialLocalizations.delegate,
                PersianCupertinoLocalizations.delegate,
                ...AppLocalizations.localizationsDelegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: value.themeMode,
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}
