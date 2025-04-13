import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';

class SingleStationSelectionDropdown extends StatefulWidget {
  const SingleStationSelectionDropdown({super.key});

  @override
  State<SingleStationSelectionDropdown> createState() =>
      _SingleStationSelectionDropdownState();
}

class _SingleStationSelectionDropdownState
    extends State<SingleStationSelectionDropdown> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.watch<Preferences>().activeUser;
    final selectedStationState = context.watch<SelectedStationsProvider>();
    if (user == null) return Container();

    return DropdownMenu(
      initialSelection: selectedStationState.singleSelectedStation,
      onSelected: (code) {
        selectedStationState.setSingleSelectedStation(code);
      },
      width: 300,
      hintText: localizations.chooseStation,
      dropdownMenuEntries:
          user.stations
              .map(
                (item) =>
                    DropdownMenuEntry(value: item.code, label: item.title),
              )
              .toList(),
    );
  }
}
