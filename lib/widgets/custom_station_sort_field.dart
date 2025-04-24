import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/cancel_button.dart';
import 'package:tmms_shifts_client/widgets/delete_button.dart';
import 'package:tmms_shifts_client/widgets/ok_button.dart';
import 'package:tmms_shifts_client/widgets/vertical_scrollable.dart';

class CustomStationSortField extends StatelessWidget {
  const CustomStationSortField({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final preferences = context.watch<Preferences>();
    final preferencesRead = context.read<Preferences>();
    final user = preferences.activeUser;
    final selectedSort = preferences.selectedCustomSort;
    if (user == null) return Container();

    final entries =
        user.customStationSort?.map((item) {
          final thisSortIsSelected =
              (selectedSort != null && selectedSort.id == item.id);

          return DropdownMenuEntry(
            value: item.id,
            label: item.title,
            leadingIcon:
                thisSortIsSelected ? selectedCheckIcon : unselectedCheckIcon,
            labelWidget:
                thisSortIsSelected ? Helpers.boldText(item.title) : null,
          );
        }).toList();

    final selectionField = DropdownMenu<int?>(
      initialSelection: selectedSort?.id,
      onSelected: (sort) {
        preferencesRead.setSelectedCustomSort(
          user.customStationSort?.where((e) => e.id == sort).firstOrNull,
        );
        if (sort == null) {
          Helpers.removeQueryFromPath(context, customSortKey);
        } else {
          Helpers.addQueryToPath(context, customSortKey, sort.toString());
        }
      },
      width: 300,
      hintText: localizations.customSort,
      dropdownMenuEntries: [
        DropdownMenuEntry(value: null, label: localizations.none),
        if (entries != null) ...entries,
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Helpers.boldText(localizations.customSort),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Icon(Icons.folder_special, size: 40),
              selectionField,
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Helpers.showEditDialogAndHandleResult(
                      context,
                      AlertDialog(),
                    );
                  },
                  label: Text(localizations.edit),
                  icon: Icon(Icons.edit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget editDialog() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Preferences.instance(),
          key: const ObjectKey(
            "Custom station sort dialog preferences provider",
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          // So that we can refresh it using the DataFetchError's refresh button
          // if needed.
          context.watch<Preferences>();
          final localizations = AppLocalizations.of(context)!;
          final preferencesRead = context.read<Preferences>();
          final user = preferencesRead.activeUser;
          final selectedSort = preferencesRead.selectedCustomSort;

          return AlertDialog(
            title: Text(localizations.newReport),
            content: SizedBox(
              width: 800,
              height: 800,
              child: VerticalScrollable(
                child: SizedBox(
                  width: 800,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [const SizedBox(height: 8)],
                  ),
                ),
              ),
            ),
            actions: [
              DeleteButton(
                onPressed: () async {
                  if (selectedSort == null) return;
                  final instance = NetworkInterface.instance();
                  final result = await instance.removeCustomStationGroup(
                    selectedSort.id,
                  );

                  if (!context.mounted) return;
                  if (result == null) {
                    context.pop(instance.lastErrorUserFriendly);
                  } else {
                    context.pop();
                  }
                },
              ),
              // OkButton(
              //   onPressed: () async {
              //     if (selectedSort == null) return;

              //     final instance = NetworkInterface.instance();
              //     final oldMeter = int.parse(_oldMeterAmountController.text);
              //     final newMeter = int.parse(_newMeterAmountController.text);
              //     final oldCorrector = int.parse(
              //       _oldCorrectorAmountController.text,
              //     );
              //     final newCorrector = int.parse(
              //       _newCorrectorAmountController.text,
              //     );

              //     final Object? result;

              //     if (_currentlyEditingReport != null) {
              //       final item = _currentlyEditingReport!;
              //       result = await instance.updateCorrectorChangeEvent(
              //         PutUpdateCorrectorChangeEventRequest(
              //           id: item.id,
              //           oldMeterAmount: oldMeter,
              //           newMeterAmount: newMeter,
              //           ran: item.ran,
              //           date: item.date,
              //           oldCorrectorAmount: oldCorrector,
              //           newCorrectorAmount: newCorrector,
              //           ranSequence: item.ranSequence,
              //           user: item.user,
              //           registeredDatetime: item.registeredDatetime,
              //           stationCode: item.stationCode,
              //         ),
              //       );
              //     } else {
              //       final ran = selectedRanState.selectedRan;
              //       final date = datePickerState.reportDate;
              //       result = await instance.createCorrectorChangeEvent(
              //         PostCreateCorrectorChangeEventRequest(
              //           oldMeterAmount: oldMeter,
              //           newMeterAmount: newMeter,
              //           oldCorrectorAmount: oldCorrector,
              //           newCorrectorAmount: newCorrector,
              //           ran: ran,
              //           date: date,
              //         ),
              //       );
              //     }
              //     if (context.mounted && result == null) {
              //       context.pop(instance.lastErrorUserFriendly);
              //     } else if (context.mounted) {
              //       context.pop();
              //     }
              //   },
              // ),
              const CancelButton(),
            ],
          );
        },
      ),
    );
  }
}
