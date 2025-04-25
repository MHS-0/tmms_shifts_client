import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';

class StationSelectionField extends StatelessWidget {
  const StationSelectionField({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null || user.stations.isEmpty) return Container();

    final selectedStationsState = context.read<SelectedStationsProvider>();
    final selectedStations = selectedStationsState.selectedStations;
    return Center(
      child: SizedBox(
        width: 300,
        child: MultiSelectDialogField(
          confirmText: Text(localizations.okButtonText),
          cancelText: Text(localizations.cancelButtonText),
          searchHint: localizations.searchFieldLabel,
          buttonText: Text(localizations.chooseStation),
          dialogHeight: 500,
          dialogWidth: 500,
          title: Text(localizations.chooseStation),
          initialValue:
              user.stations
                  .where((e) => selectedStations.contains(e.code))
                  .toList(),
          items:
              user.stations
                  .map((Station e) => MultiSelectItem(e, e.title))
                  .toList(),
          onConfirm: (list) {
            final codes = list.map((entry) => entry.code).toList();
            selectedStationsState.setSelectedStations(codes);
            if (codes.isEmpty) {
              Helpers.removeQueryFromPath(context, stationCodesKey);
            } else {
              Helpers.addQueryToPath(context, stationCodesKey, codes.join(","));
            }
          },
        ),
      ),
    );
  }
}
