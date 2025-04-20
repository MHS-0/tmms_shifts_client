import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';

class CounterReplacementEventsRoute extends StatefulWidget {
  static const routingName = "CounterReplacementEventsRoute";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;

  const CounterReplacementEventsRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
  });

  @override
  State<CounterReplacementEventsRoute> createState() =>
      _CounterReplacementEventsRouteState();
}

class _CounterReplacementEventsRouteState
    extends State<CounterReplacementEventsRoute> {
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
              title: Text(localizations.dataCounterReplacementEventEntry),
              centerTitle: true,
            ),
            drawer: MyDrawer(),
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
