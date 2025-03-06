import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/routes/corrector_replacement_event_register.dart';
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
      builder: (_, __) {
        return const MainRoute();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) {
        return const LoginRoute();
      },
    ),
    GoRoute(
      path: '/corrector-replacement-event-register',
      builder: (_, __) {
        return const CorrectorReplacementEventRegisterRoute();
      },
    ),
    GoRoute(
      path: '/counter-replacement-event-register',
      builder: (_, __) {
        return const CorrectorReplacementEventRegisterRoute();
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
    return MaterialPage(child: PageNotFoundRoute());
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
              locale: value.locale,
              onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
              // The below two lines are needed for localizations. They set the supported
              // languages for this app and make the AppLocalizations.of callback available.
              localizationsDelegates: AppLocalizations.localizationsDelegates,
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
