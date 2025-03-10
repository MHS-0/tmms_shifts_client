import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/routes/corrector_replacement_event_register.dart';
import 'package:tmms_shifts_client/routes/counter_corrector_reports.dart';
import 'package:tmms_shifts_client/routes/counter_replacement_event_register.dart';
import 'package:tmms_shifts_client/routes/login.dart';
import 'package:tmms_shifts_client/routes/main_route.dart';
import 'package:tmms_shifts_client/routes/page_not_found_route.dart';
import 'package:tmms_shifts_client/theme.dart';
import 'l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
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
      pageBuilder: (_, __) {
        return const MaterialPage(child: MainRoute());
      },
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (_, __) {
        return const MaterialPage(child: LoginRoute());
      },
    ),
    GoRoute(
      path: '/corrector-replacement-event-register',
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
      path: '/counter-corrector-reports',
      pageBuilder: (_, __) {
        return const MaterialPage(child: CounterCorrectorReportsRoute());
      },
    ),
    GoRoute(
      path: '/counter-corrector-reports/:report',
      pageBuilder: (_, state) {
        final report = state.pathParameters["report"];
        if (report == null) {
          return const MaterialPage(child: CounterCorrectorReportsRoute());
        }
        final reportNumber = int.tryParse(report);
        if (reportNumber == null) {
          // TODO
          // Maybe instead we should re-route to the 404 page?
          return const MaterialPage(child: CounterCorrectorReportsRoute());
        }
        return MaterialPage(
          child: CounterCorrectorReportsRoute(report: reportNumber),
        );
      },
    ),
  ],
  redirect: (context, state) {
    final loggedIn = context.read<Preferences>().activeUser != null;
    if (!loggedIn) {
      return "/login";
    }
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
              debugShowCheckedModeBanner: false,
              restorationScopeId: 'tmms-shifts-client',
              locale: Preferences.persianLocale,
              onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
              // The below two lines are needed for localizations. They set the supported
              // languages for this app and make the AppLocalizations.of callback available.
              localizationsDelegates: [
                PersianMaterialLocalizations.delegate,
                PersianCupertinoLocalizations.delegate,
                ...AppLocalizations.localizationsDelegates,
              ],
              supportedLocales: [
                Locale('fa', 'IR'),
                Locale('fa'),
                Locale('en'),
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale?.languageCode == 'fa') {
                  return const Locale(
                    'fa',
                  ); // Use generic Persian if fa-IR isn't found
                }
                return supportedLocales.contains(locale)
                    ? locale
                    : const Locale('en');
              },
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
