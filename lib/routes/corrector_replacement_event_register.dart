import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';

class CorrectorReplacementEventsRoute extends StatefulWidget {
  static const routingName = "CorrectorReplacementEventsRoute";

  const CorrectorReplacementEventsRoute({super.key});

  @override
  State<CorrectorReplacementEventsRoute> createState() =>
      _CorrectorReplacementEventsRouteState();
}

class _CorrectorReplacementEventsRouteState
    extends State<CorrectorReplacementEventsRoute> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.watch<Preferences>().activeUser;
    if (user == null || user.stations.isEmpty) return Scaffold();

    return Consumer<Preferences>(
      builder: (_, preferences, __) {
        return SelectionArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(localizations.dataCorrectorReplacementEventEntry),
              centerTitle: true,
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
