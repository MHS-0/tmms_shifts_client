import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/routes/corrector_replacement_event_register.dart';
import 'package:tmms_shifts_client/routes/counter_corrector_report_view.dart';
import 'package:tmms_shifts_client/routes/counter_corrector_reports.dart';
import 'package:tmms_shifts_client/routes/counter_replacement_event_register.dart';
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

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: MonitoringFullReportRoute.routingName,
      pageBuilder: (_, state) {
        final queries = state.uri.queryParameters;
        return MaterialPage(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => SelectedStationsProvider()),
              ChangeNotifierProvider(create: (_) => DatePickerProvider()),
            ],
            child: MonitoringFullReportRoute(
              stationCodes: queries["stationCodes"],
              fromDate: queries["fromDate"],
              toDate: queries["toDate"],
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: '/404',
      name: PageNotFoundRoute.routingName,
      pageBuilder: (_, __) {
        return const MaterialPage(child: PageNotFoundRoute());
      },
    ),
    GoRoute(
      path: '/login',
      name: LoginRoute.routingName,
      pageBuilder: (_, __) {
        return const MaterialPage(child: LoginRoute());
      },
    ),
    GoRoute(
      path: '/corrector-replacement-event-register',
      name: "correctorReplacementEventRegister",
      pageBuilder: (_, __) {
        return const MaterialPage(
          child: CorrectorReplacementEventRegisterRoute(),
        );
      },
    ),
    GoRoute(
      path: '/counter-replacement-event-register',
      pageBuilder: (_, __) {
        return const MaterialPage(
          child: CounterReplacementEventRegisterRoute(),
        );
      },
    ),
    GoRoute(
      path: '/pressure-and-temp-reports',
      name: PressureAndTempReportsRoute.routingName,
      pageBuilder: (_, state) {
        final queries = state.uri.queryParameters;
        return MaterialPage(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => SelectedStationsProvider()),
              ChangeNotifierProvider(create: (_) => DatePickerProvider()),
            ],
            child: PressureAndTempReportsRoute(
              stationCodes: queries["stationCodes"],
              fromDate: queries["fromDate"],
              toDate: queries["toDate"],
            ),
          ),
        );
      },
      routes: [
        // GoRoute(
        //   path: '/:report',
        //   name: CounterCorrectorReportViewRoute.routingName,
        //   pageBuilder: (_, state) {
        //     final report = state.pathParameters["report"];
        //     if (report == null) {
        //       return const MaterialPage(child: CounterCorrectorReportsRoute());
        //     }
        //     final reportNumber = int.tryParse(report);
        //     if (reportNumber == null) {
        //       return const MaterialPage(child: CounterCorrectorReportsRoute());
        //     }
        //     return MaterialPage(
        //       child: CounterCorrectorReportViewRoute(report: reportNumber),
        //     );
        //   },
        // ),
      ],
    ),
    GoRoute(
      path: '/counter-corrector-reports',
      name: CounterCorrectorReportsRoute.routingName,
      pageBuilder: (_, __) {
        return const MaterialPage(child: CounterCorrectorReportsRoute());
      },
      routes: [
        GoRoute(
          path: '/:report',
          name: CounterCorrectorReportViewRoute.routingName,
          pageBuilder: (_, state) {
            final report = state.pathParameters["report"];
            if (report == null) {
              return const MaterialPage(child: CounterCorrectorReportsRoute());
            }
            final reportNumber = int.tryParse(report);
            if (reportNumber == null) {
              return const MaterialPage(child: CounterCorrectorReportsRoute());
            }
            return MaterialPage(
              child: CounterCorrectorReportViewRoute(report: reportNumber),
            );
          },
        ),
      ],
    ),
  ],
  redirect: (context, state) async {
    final user = context.read<Preferences>().activeUser;
    final loggedIn = user != null;
    if (!loggedIn) {
      return "/login";
    }

    // FIXME: Enable this again in production!!!
    // // Logout if session is expired. For example if the password of the user
    // // has been changed.
    // try {
    // await NetworkInterface.instance().getProfile(user.token);
    // } catch (e) {
    //   Preferences.log.warning(e);
    //   Preferences.log.info("Logging out");
    //   await Preferences.instance().unsetActiveUser();
    //   return "/login";
    // }

    if (loggedIn && state.uri.path.contains("login")) {
      return "/";
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
