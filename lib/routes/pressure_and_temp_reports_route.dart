import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/widgets/cancel_button.dart';
import 'package:tmms_shifts_client/widgets/data_fetch_error.dart';
import 'package:tmms_shifts_client/widgets/date_picker_row.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';
import 'package:tmms_shifts_client/widgets/excel_export_button.dart';
import 'package:tmms_shifts_client/widgets/ok_button.dart';
import 'package:tmms_shifts_client/widgets/single_station_selection_dropdown.dart';
import 'package:tmms_shifts_client/widgets/station_selection_field.dart';
import 'package:tmms_shifts_client/widgets/title_and_text_field_row.dart';

class PressureAndTempReportsRoute extends StatefulWidget {
  static const routingName = "pressure_and_temp_reports_route";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;

  const PressureAndTempReportsRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
  });

  @override
  State<PressureAndTempReportsRoute> createState() =>
      _PressureAndTempReportsRouteState();
}

class _PressureAndTempReportsRouteState
    extends State<PressureAndTempReportsRoute> {
  final _formKey = GlobalKey<FormState>();

  String? selectedShift;
  GetPressureAndTemperatureFullReportResponseResultItem?
  _currentlyEditingReport;

  final _inputPressureController = TextEditingController();
  final _outputPressureController = TextEditingController();
  final _inputTempController = TextEditingController();
  final _outputTempController = TextEditingController();

  final List<ScrollController> _mainScrollControllers = [];
  final List<ScrollController> _dialogScrollControllers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Helpers.initialRouteSetup(context);
  }

  Future<GetPressureAndTemperatureFullReportResponse> getPressureAndTempReports(
    BuildContext context,
  ) async {
    final instance = NetworkInterface.instance();
    final result = await instance.getPressureAndTemperatureFullReport(
      query: ToFromDateStationsQuery(
        fromDate: widget.fromDate,
        toDate: widget.toDate,
        stationCodes: Helpers.serializeStringIntoIntList(widget.stationCodes),
      ),
    );
    return await Helpers.returnWithErrorIfNeeded(result);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.watch<Preferences>().activeUser;
    final selectedStationState = context.read<SelectedStationsProvider>();
    if (user == null || user.stations.isEmpty) return Scaffold();

    clearMainScrollControllers();
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.reportPressureAndTemp)),
        drawer: const MyDrawer(),
        body: FutureBuilder(
          future: getPressureAndTempReports(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DataFetchError(content: snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return centeredCircularProgressIndicator;
            } else {
              return ListView(
                padding: offsetAll16p,
                children: [
                  const SizedBox(),
                  const StationSelectionField(),
                  const DatePickerRow(),
                  ExcelExportButton(
                    data:
                        snapshot.data!.results.map((e) => e.toJson()).toList(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 50,
                        width: 165,
                        child: FilledButton.icon(
                          label: Text(localizations.newReport),
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            _currentlyEditingReport = null;
                            selectedShift = null;
                            setupTextControllers();
                            selectedStationState.setSingleSelectedStation(null);
                            await showEditDialogAndHandleResult(
                              context,
                              selectedStationState,
                              localizations,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  ..._getPressureAndTempReportCards(
                    context,
                    snapshot.data!.results,
                    localizations,
                    user,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _getPressureAndTempReportCards(
    BuildContext context,
    List<GetPressureAndTemperatureFullReportResponseResultItem> results,
    AppLocalizations localizations,
    ActiveUser user,
  ) {
    return results.map((item) {
      final controller = ScrollController();
      final stationOfItem =
          user.stations
              .where((entry) => entry.code == item.stationCode)
              .firstOrNull;

      return InkWell(
        onTap: () async {
          _currentlyEditingReport = item;
          selectedShift = item.shifts.firstOrNull?.shift ?? "06";

          final selectedStationState = context.read<SelectedStationsProvider>();
          setupTextControllers();
          selectedStationState.setSingleSelectedStation(item.stationCode);

          await showEditDialogAndHandleResult(
            context,
            selectedStationState,
            localizations,
          );
        },
        child: Padding(
          padding: offsetAll16p,
          child: Card(
            margin: offsetAll16p,
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Helpers.boldText(
                    '${localizations.station}: ${stationOfItem?.title ?? ""}',
                  ),
                  Helpers.boldText(
                    '${localizations.date}: ${dateFormatter.format(DateTime.parse(item.date.toJalaliDateTime()))}',
                  ),
                  Helpers.cardTitleDetailsRow([
                    '${localizations.district}: ${stationOfItem?.district}',
                    '${localizations.area}: ${stationOfItem?.area}',
                  ]),
                  Helpers.cardTitleDetailsRow([
                    '${localizations.stationCode}: ${stationOfItem?.code}',
                    '${localizations.capacity}: ${stationOfItem?.capacity}',
                  ]),
                ],
              ),
              children: [
                Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: SingleChildScrollView(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = MediaQuery.of(context).size.width;
                        // if (width >= 1200) {
                        return DataTable(
                          headingRowColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.inversePrimary,
                          ),
                          columns: Helpers.getDataColumns(
                            context,
                            [
                              localizations.shift,
                              localizations.inputPressure,
                              localizations.outputPressure,
                              localizations.inputTemp,
                              localizations.outputTemp,
                              localizations.registeredDate,
                              localizations.user,
                            ],
                            8,
                            150,
                          ),
                          rows:
                              item.shifts
                                  .map<DataRow>(
                                    (shift) => DataRow(
                                      cells: Helpers.getDataCells([
                                        shift.shift,
                                        shift.inputPressure,
                                        shift.outputPressure,
                                        shift.inputTemperature,
                                        shift.outputTemperature,
                                        shift.registeredDatetime != null
                                            ? dateFormatterWithHour.format(
                                              DateTime.parse(
                                                shift.registeredDatetime!
                                                    .toJalaliDateTime(),
                                              ),
                                            )
                                            : "",
                                        shift.user ?? "",
                                      ]),
                                    ),
                                  )
                                  .toList(),
                        );
                        // } else {
                        //   return Container();
                        // }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void setupTextControllers() {
    Shift? shift;
    if (selectedShift != null) {
      shift =
          _currentlyEditingReport?.shifts
              .where((item) => item.shift.contains(selectedShift!))
              .firstOrNull;
    }
    _inputPressureController.text = shift?.inputPressure.toString() ?? "";
    _outputPressureController.text = shift?.outputPressure.toString() ?? "";
    _inputTempController.text = shift?.inputTemperature.toString() ?? "";
    _outputTempController.text = shift?.outputTemperature.toString() ?? "";
  }

  Future<GetShiftDataBulkLastActionResponse> getShiftDataLastAction(
    int stationCode,
  ) async {
    final instance = NetworkInterface.instance();
    final result = await instance.getShiftDataBulkLastAction(
      SingleStationQuery(stationCode),
    );
    return await Helpers.returnWithErrorIfNeeded(result);
  }

  Widget reportEditDialog(
    SelectedStationsProvider selectedStationState,
    AppLocalizations localizations,
  ) {
    return ChangeNotifierProvider.value(
      value: selectedStationState,
      key: const ObjectKey("Pressure and temp dialog provider"),
      child: Consumer<SelectedStationsProvider>(
        builder: (context, value, _) {
          clearDialogScrollControllers();
          final scrollController = ScrollController();
          _dialogScrollControllers.add(scrollController);

          // So that we can refresh it using the DataFetchError's refresh button
          // if needed.
          context.watch<Preferences>();

          final singleStation = selectedStationState.singleSelectedStation;

          FutureBuilder? lastActionFuture;
          if (singleStation != null) {
            lastActionFuture =
                FutureBuilder<GetShiftDataBulkLastActionResponse>(
                  future: getShiftDataLastAction(singleStation),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return DataFetchError(content: snapshot.error.toString());
                    } else if (!snapshot.hasData) {
                      return SizedBox(
                        height: 50,
                        width: 50,
                        child: centeredCircularProgressIndicator,
                      );
                    } else {
                      final shift = snapshot.data!;

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
                          175,
                        ),
                        rows: [
                          DataRow(
                            cells: Helpers.getDataCells([
                              shift.shift,
                              Helpers.jalaliToDashDate(shift.date),
                              Helpers.serializeJalaliIntoIso8601(
                                shift.registeredDatetime,
                              ),
                              shift.inputPressure,
                              shift.outputPressure,
                              shift.inputTemperature,
                              shift.outputTemperature,
                              shift.station,
                            ]),
                          ),
                        ],
                      );
                    }
                  },
                );
          }

          return AlertDialog(
            title: Text(localizations.newReport),
            content: SizedBox(
              width: 1200,
              height: 800,
              child: SingleChildScrollView(
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: scrollController,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1200,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 16,
                          children: [
                            if (lastActionFuture != null) ...[
                              Text(localizations.lastAction),
                              lastActionFuture,
                              SizedBox(),
                            ],
                            if (_currentlyEditingReport == null)
                              Helpers.titleAndWidgetRow(
                                localizations.station,
                                const SingleStationSelectionDropdown(),
                              ),
                            Helpers.titleAndWidgetRow(
                              localizations.shift,
                              DropdownMenu(
                                initialSelection: selectedShift,
                                onSelected: (shift) {
                                  if (shift == null) return;

                                  selectedShift = shift;
                                  setupTextControllers();
                                  setState(() {});
                                },
                                width: 300,
                                hintText: localizations.shift,
                                dropdownMenuEntries:
                                    ["06", "12", "18", "24"].map((entry) {
                                      return DropdownMenuEntry(
                                        value: entry,
                                        label: entry,
                                      );
                                    }).toList(),
                              ),
                            ),
                            TitleAndTextFieldRow(
                              title: localizations.inputPressure,
                              controller: _inputPressureController,
                              numbersOnly: true,
                            ),
                            TitleAndTextFieldRow(
                              title: localizations.outputPressure,
                              controller: _outputPressureController,
                              numbersOnly: true,
                            ),
                            TitleAndTextFieldRow(
                              title: localizations.inputTemp,
                              controller: _inputTempController,
                              numbersOnly: true,
                            ),
                            TitleAndTextFieldRow(
                              title: localizations.outputTemp,
                              controller: _outputTempController,
                              numbersOnly: true,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              OkButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      selectedShift != null &&
                      selectedStationState.singleSelectedStation != null) {
                    final instance = NetworkInterface.instance();
                    final inputPressure = int.parse(
                      _inputPressureController.text,
                    );
                    final outputPressure = int.parse(
                      _outputPressureController.text,
                    );
                    final inputTemp = int.parse(_inputTempController.text);
                    final outputTemp = int.parse(_outputTempController.text);

                    final Object? result;

                    if (_currentlyEditingReport != null) {
                      final shift = _currentlyEditingReport!;
                      result = await instance.updateShiftData(
                        UpdateShiftDataRequest(
                          station: shift.stationCode,
                          shift: selectedShift!,
                          date: shift.date,
                          inputPressure: inputPressure,
                          outputPressure: outputPressure,
                          inputTemperature: inputTemp,
                          outputTemperature: outputTemp,
                        ),
                        // FIXME: This should be the shift id, but right now, it's not provided in the response
                        // Should ask for it to be included if possible.
                        2,
                      );
                    } else {
                      result = await instance.createShiftData(
                        CreateShiftDataRequest(
                          station: selectedStationState.singleSelectedStation!,
                          shift: selectedShift!,
                          date: Jalali.now(),
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
        },
      ),
    );
  }

  Future<void> showEditDialogAndHandleResult(
    BuildContext context,
    SelectedStationsProvider selectedStationState,
    AppLocalizations localizations,
  ) async {
    final String? result = await Helpers.showCustomDialog(
      context,
      reportEditDialog(selectedStationState, localizations),
      barrierDismissable: true,
    );
    clearDialogScrollControllers();
    if (context.mounted && result != null) {
      await Helpers.showCustomDialog(
        context,
        ErrorAlertDialog(result),
        barrierDismissable: true,
      );
    } else if (context.mounted) {
      context.read<Preferences>().refreshRoute();
    }
  }

  void clearDialogScrollControllers() {
    for (final entry in _dialogScrollControllers) {
      entry.dispose();
    }
    _dialogScrollControllers.clear();
  }

  void clearMainScrollControllers() {
    for (final entry in _mainScrollControllers) {
      entry.dispose();
    }
    _mainScrollControllers.clear();
  }

  @override
  void dispose() {
    clearDialogScrollControllers();
    clearMainScrollControllers();
    _inputPressureController.dispose();
    _outputPressureController.dispose();
    _inputTempController.dispose();
    _outputTempController.dispose();
    super.dispose();
  }
}
