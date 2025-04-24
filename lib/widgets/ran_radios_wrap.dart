import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_ran_provider.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';

class RanRadiosWrap extends StatelessWidget {
  const RanRadiosWrap({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.watch<Preferences>().activeUser;
    final selectedStation =
        context.watch<SelectedStationsProvider>().singleSelectedStation;
    final selectedRan = context.watch<SelectedRanProvider>().selectedRan;
    if (user == null || selectedStation == null) return const SizedBox();

    final rans =
        user.stations
            .where((e) => e.code == selectedStation)
            .firstOrNull
            ?.rans ??
        [];

    List<Widget> radios = [];
    for (final entry in rans) {
      final child = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Radio<int>(
            fillColor: WidgetStatePropertyAll(Colors.lightGreen),
            value: entry.code,
            groupValue: selectedRan,
            onChanged: null,
          ),
          Text("${localizations.ran} ${entry.sequenceNumber}"),
        ],
      );

      final Widget widget;
      if (selectedRan == entry.code) {
        widget = FilledButton(onPressed: () {}, child: child);
      } else {
        widget = ElevatedButton(
          onPressed: () {
            context.read<SelectedRanProvider>().setSelectedRan(entry.code);
          },
          child: child,
        );
      }
      radios.add(
        Tooltip(
          margin: offsetAll8p,
          message: "${localizations.ran}: ${entry.code}",
          child: Padding(padding: offsetAll8p, child: widget),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: offsetAll32p,
        child: Wrap(spacing: 32, runSpacing: 16, children: radios),
      ),
    );
  }
}
