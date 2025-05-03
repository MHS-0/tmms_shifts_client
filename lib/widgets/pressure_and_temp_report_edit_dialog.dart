import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/widgets/cancel_button.dart';
import 'package:tmms_shifts_client/widgets/data_fetch_future_builder.dart';
import 'package:tmms_shifts_client/widgets/date_picker_single_field.dart';
import 'package:tmms_shifts_client/widgets/delete_button.dart';
import 'package:tmms_shifts_client/widgets/ok_button.dart';
import 'package:tmms_shifts_client/widgets/single_station_selection_dropdown.dart';
import 'package:tmms_shifts_client/widgets/title_and_text_field_row.dart';
import 'package:tmms_shifts_client/widgets/vertical_horizontal_scrollable.dart';

class PressureAndTempReportEditDialog extends StatefulWidget {
  final GetPressureAndTemperatureFullReportResponseResultItem? entry;

  const PressureAndTempReportEditDialog({super.key, this.entry});

  @override
  State<PressureAndTempReportEditDialog> createState() =>
      _PressureAndTempReportEditDialogState();
}

class _PressureAndTempReportEditDialogState
    extends State<PressureAndTempReportEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textControllers = List.generate(
    16,
    (index) => TextEditingController(),
  );

  /// Assign:
  /// 0 to the 06 shift,
  /// 1 to the 12 shift,
  /// 2 to the 18 shift,
  /// 3 to the 24 shift
  ///
  /// Used for indexing the _textControllers.
  late int _selectedShift =
      (int.parse(
                widget.entry?.shifts.firstOrNull?.shift.replaceAll('0', '') ??
                    "6",
              ) /
              6)
          .toInt() -
      1;

  Future<GetShiftDataBulkLastActionResponse> getShiftDataLastAction(
    int stationCode,
  ) async {
    final instance = NetworkInterface.instance();
    final result = await instance.getShiftDataBulkLastAction(
      SingleStationQuery(stationCode),
    );
    return await Helpers.returnWithErrorIfNeeded(result);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.entry != null) {
      for (final item in widget.entry!.shifts) {
        switch (item.shift) {
          case "06":
            _textControllers[0].text = item.inputPressure.toString();
            _textControllers[1].text = item.outputPressure.toString();
            _textControllers[2].text = item.inputTemperature.toString();
            _textControllers[3].text = item.outputTemperature.toString();
            break;
          case "12":
            _textControllers[4].text = item.inputPressure.toString();
            _textControllers[5].text = item.outputPressure.toString();
            _textControllers[6].text = item.inputTemperature.toString();
            _textControllers[7].text = item.outputTemperature.toString();
            break;
          case "18":
            _textControllers[8].text = item.inputPressure.toString();
            _textControllers[9].text = item.outputPressure.toString();
            _textControllers[10].text = item.inputTemperature.toString();
            _textControllers[11].text = item.outputTemperature.toString();
            break;
          case "24":
            _textControllers[12].text = item.inputPressure.toString();
            _textControllers[13].text = item.outputPressure.toString();
            _textControllers[14].text = item.inputTemperature.toString();
            _textControllers[15].text = item.outputTemperature.toString();
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final selectedStationState = context.watch<SelectedStationsProvider>();
    context.watch<DatePickerProvider>();
    final singleStation = selectedStationState.singleSelectedStation;
    // So that we can refresh it using the DataFetchError's refresh button
    // if needed.
    context.watch<Preferences>();

    Widget? lastActionFuture;
    if (singleStation != null) {
      lastActionFuture = DataFetchFutureBuilder(
        future: getShiftDataLastAction(singleStation),
        builder: (context, shift) {
          return DataTable(
            headingRowColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.inversePrimary,
            ),
            columns: Helpers.getDataColumns(
              context,
              [
                localizations.shift,
                localizations.date,
                localizations.registeredDate,
                localizations.inputPressure,
                localizations.outputPressure,
                localizations.inputTemp,
                localizations.outputTemp,
                localizations.stationCode,
              ],
              8,
              210,
            ),
            rows: [
              DataRow(
                cells: Helpers.getDataCells([
                  shift.shift,
                  Helpers.jalaliToDashDate(shift.date),
                  Helpers.serializeJalaliIntoIso8601(shift.registeredDatetime),
                  shift.inputPressure,
                  shift.outputPressure,
                  shift.inputTemperature,
                  shift.outputTemperature,
                  shift.station,
                ]),
              ),
            ],
          );
        },
      );
    }

    return AlertDialog(
      title: Text(localizations.newReport),
      content: SizedBox(
        width: 1500,
        height: 800,
        child: BothScrollable(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16,
              children: [
                if (lastActionFuture != null) ...[
                  Text(localizations.lastAction),
                  lastActionFuture,
                  SizedBox(),
                ],
                if (widget.entry == null) ...[
                  Helpers.titleAndWidgetRow(
                    "${localizations.station} :",
                    const SingleStationSelectionDropdown(),
                  ),
                  const DatePickerSingleField(),
                ],
                Helpers.titleAndWidgetRow(
                  "${localizations.shift} :",
                  DropdownMenu(
                    initialSelection: _selectedShift,
                    onSelected: (shift) {
                      if (shift == null) return;

                      _selectedShift = shift;
                      setState(() {});
                    },
                    width: 300,
                    hintText: localizations.shift,
                    dropdownMenuEntries:
                        ["06", "12", "18", "24"].indexed.map((entry) {
                          return DropdownMenuEntry(
                            value: entry.$1,
                            label: entry.$2,
                          );
                        }).toList(),
                  ),
                ),
                TitleAndTextFieldRow(
                  title: localizations.inputPressure,
                  controller: _textControllers[0 + (_selectedShift * 4)],
                  numbersOnly: true,
                ),
                TitleAndTextFieldRow(
                  title: localizations.outputPressure,
                  controller: _textControllers[1 + (_selectedShift * 4)],
                  numbersOnly: true,
                ),
                TitleAndTextFieldRow(
                  title: localizations.inputTemp,
                  controller: _textControllers[2 + (_selectedShift * 4)],
                  numbersOnly: true,
                ),
                TitleAndTextFieldRow(
                  title: localizations.outputTemp,
                  controller: _textControllers[3 + (_selectedShift * 4)],
                  numbersOnly: true,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (context.read<Preferences>().activeUser!.isStaff &&
            widget.entry != null)
          DeleteButton(
            onPressed: () async {
              final instance = NetworkInterface.instance();
              bool? result;

              for (final entry in widget.entry!.shifts) {
                result = await instance.destroyShiftData(entry.id);

                if (!context.mounted) return;
                if (result == null) {
                  context.pop(instance.lastErrorUserFriendly);
                  return;
                }
              }
              context.pop();
            },
          ),
        OkButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() &&
                selectedStationState.singleSelectedStation != null) {
              final selectedStationState =
                  context.read<SelectedStationsProvider>();
              final datePickerState = context.read<DatePickerProvider>();
              final instance = NetworkInterface.instance();
              Object? result;

              final inputPressure = int.parse(
                _textControllers[0 + (_selectedShift * 4)].text,
              );
              final outputPressure = int.parse(
                _textControllers[1 + (_selectedShift * 4)].text,
              );
              final inputTemp = int.parse(
                _textControllers[2 + (_selectedShift * 4)].text,
              );
              final outputTemp = int.parse(
                _textControllers[3 + (_selectedShift * 4)].text,
              );

              final String selectedShiftString;
              if (_selectedShift != 0) {
                selectedShiftString = ((_selectedShift + 1) * 6).toString();
              } else {
                selectedShiftString = "06";
              }

              if (widget.entry != null) {
                final shift = widget.entry!;
                result = await instance.updateShiftData(
                  UpdateShiftDataRequest(
                    station: shift.stationCode,
                    shift: selectedShiftString,
                    date: shift.date,
                    inputPressure: inputPressure,
                    outputPressure: outputPressure,
                    inputTemperature: inputTemp,
                    outputTemperature: outputTemp,
                  ),
                  shift.shifts
                      .where((e) => e.shift == selectedShiftString)
                      .firstOrNull!
                      .id,
                );
              } else {
                final date = datePickerState.reportDate;
                result = await instance.createShiftData(
                  CreateShiftDataRequest(
                    station: selectedStationState.singleSelectedStation!,
                    shift: selectedShiftString,
                    date: date,
                    inputPressure: inputPressure,
                    outputPressure: outputPressure,
                    inputTemperature: inputTemp,
                    outputTemperature: outputTemp,
                  ),
                );
              }
              if (context.mounted && result == null) {
                context.pop(instance.lastErrorUserFriendly);
              } else if (context.mounted) {
                context.pop();
              }
            }
          },
        ),
        const CancelButton(),
      ],
    );
  }

  @override
  void dispose() {
    for (final item in _textControllers) {
      item.dispose();
    }
    _textControllers.clear();
    super.dispose();
  }
}
