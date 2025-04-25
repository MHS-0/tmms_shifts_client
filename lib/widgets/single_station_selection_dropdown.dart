import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/helpers.dart';
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
    final user = context.read<Preferences>().activeUser;
    final selectedStationState = context.watch<SelectedStationsProvider>();
    final selectedStation = selectedStationState.singleSelectedStation;
    if (user == null) return Container();

    return DropdownMenu(
      initialSelection: selectedStation,
      onSelected: (code) {
        selectedStationState.setSingleSelectedStation(code);
      },
      width: 300,
      hintText: localizations.chooseStation,
      dropdownMenuEntries:
          user.stations.map((item) {
            final thisStationIsSelected =
                (selectedStation != null && selectedStation == item.code);

            return DropdownMenuEntry(
              value: item.code,
              label: item.title,
              leadingIcon:
                  thisStationIsSelected
                      ? selectedCheckIcon
                      : unselectedCheckIcon,
              labelWidget:
                  thisStationIsSelected ? Helpers.boldText(item.title) : null,
            );
          }).toList(),
    );
  }
}
