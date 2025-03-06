import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/stations_dropdown.dart';

class MainRoute extends StatefulWidget {
  /// Creates a new Main route for the app.
  const MainRoute({super.key});

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null || user.stations.isEmpty) return Scaffold();

    return Consumer<Preferences>(
      builder: (_, preferences, __) {
        return SelectionArea(
          child: Scaffold(
            appBar: AppBar(title: Text(localizations.title), centerTitle: true),
            drawer: MyDrawer(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  StationsDropDown(),
                  Center(
                    child: Text(
                      localizations.mainStuff,
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(fontSize: 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
