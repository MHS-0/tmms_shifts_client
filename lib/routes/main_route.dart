import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';

class MainRoute extends StatefulWidget {
  /// Creates a new Main route for the app.
  const MainRoute({super.key});

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  /// Precaches the icon of the app that will be used on the about dialog so that
  /// it doesn't 'pop up' when the dialog gets built for the first time.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // TODO
    // precacheImage(const AssetImage(iconAssetPath), context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<Preferences>(
      builder: (_, preferences, __) {
        return SelectionArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(localizations.title),
              centerTitle: true,
              actions: [
                Switch(
                  value: preferences.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    switch (value) {
                      case true:
                        preferences.setTheme(ThemeMode.dark);
                      case false:
                        preferences.setTheme(ThemeMode.light);
                    }
                    setState(() {});
                  },
                ),
                Switch(
                  value: preferences.locale == Preferences.englishLocale,
                  onChanged: (value) {
                    switch (value) {
                      case true:
                        preferences.setLocale(Preferences.englishLocale);
                      case false:
                        preferences.setLocale(Preferences.persianLocale);
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
            drawer: MyDrawer(),
            body: Center(
              child: Text(
                localizations.mainStuff,
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 50),
              ),
            ),
          ),
        );
      },
    );
  }
}
