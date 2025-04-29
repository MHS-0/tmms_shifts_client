import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/providers/sort_provider.dart';
import 'package:tmms_shifts_client/widgets/cancel_button.dart';
import 'package:tmms_shifts_client/widgets/data_fetch_error.dart';
import 'package:tmms_shifts_client/widgets/date_picker_row.dart';
import 'package:tmms_shifts_client/widgets/date_picker_single_field.dart';
import 'package:tmms_shifts_client/widgets/delete_button.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/horizontal_scrollable.dart';
import 'package:tmms_shifts_client/widgets/new_report_button.dart';
import 'package:tmms_shifts_client/widgets/ok_button.dart';
import 'package:tmms_shifts_client/widgets/single_station_selection_dropdown.dart';
import 'package:tmms_shifts_client/widgets/station_selection_field.dart';
import 'package:tmms_shifts_client/widgets/title_and_text_field_row.dart';
import 'package:tmms_shifts_client/widgets/vertical_horizontal_scrollable.dart';

class PressureAndTempReportsRoute extends StatefulWidget {
  static const routingName = "pressure_and_temp_reports_route";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;
  final String? sortBy;

  const PressureAndTempReportsRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
    this.sortBy,
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

    if (context.mounted && result != null) {
      result.results = Helpers.sortResults(
        context.read<SortProvider>(),
        context.read<Preferences>().activeUser!.stations,
        result.results,
      );
    }
    return await Helpers.returnWithErrorIfNeeded(result);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.watch<Preferences>().activeUser;
    final selectedStationState = context.read<SelectedStationsProvider>();
    final sortState = context.read<SortProvider>();
    if (user == null || user.stations.isEmpty) return Scaffold();

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
              final results = snapshot.data!.results;

              return ListView(
                padding: offsetAll16p,
                children: [
                  const SizedBox(),
                  const StationSelectionField(),
                  const DatePickerRow(),
                  Helpers.getExcelExportSortRow(
                    results.map((e) => e.toJson()).toList(),
                    user.stations,
                  ),
                  const SizedBox(height: 16),
                  NewReportButton(
                    onPressed: () async {
                      _currentlyEditingReport = null;
                      selectedShift = null;
                      setupTextControllers();
                      selectedStationState.setSingleSelectedStation(null);
                      await Helpers.showEditDialogAndHandleResult(
                        context,
                        reportEditDialog(),
                      );
                    },
                  ),
                  ..._getPressureAndTempReportCards(
                    context,
                    results,
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

          await Helpers.showEditDialogAndHandleResult(
            context,
            reportEditDialog(),
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
                HorizontalScrollable(
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

  Widget reportEditDialog() {
    final localizations = AppLocalizations.of(context)!;
    final selectedStationState = context.read<SelectedStationsProvider>();
    final datePickerState = context.read<DatePickerProvider>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: selectedStationState,
          key: const ObjectKey("Pressure and temp dialog station provider"),
        ),
        ChangeNotifierProvider.value(
          value: datePickerState,
          key: const ObjectKey("Pressure and temp dialog date provider"),
        ),
      ],
      child: Builder(
        builder: (context) {
          // So that we can refresh it using the DataFetchError's refresh button
          // if needed.
          // context.watch<Preferences>();

          final selectedStationState =
              context.watch<SelectedStationsProvider>();
          final datePickerState = context.watch<DatePickerProvider>();
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
                          210,
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
              width: 1500,
              height: 800,
              child: BothScrollable(
                child: SizedBox(
                  width: 1500,
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
                        if (_currentlyEditingReport == null) ...[
                          Helpers.titleAndWidgetRow(
                            "${localizations.station} :",
                            const SingleStationSelectionDropdown(),
                          ),
                          const DatePickerSingleField(),
                        ],
                        Helpers.titleAndWidgetRow(
                          "${localizations.shift} :",
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
            actions: [
              if (context.read<Preferences>().activeUser!.isStaff &&
                  _currentlyEditingReport != null)
                DeleteButton(
                  onPressed: () async {
                    final instance = NetworkInterface.instance();
                    final result = await instance.destroyShiftData(
                      // FIXME!: Id should be included in responses. Ask backend.
                      _currentlyEditingReport!.stationCode,
                    );

                    if (!context.mounted) return;
                    if (result == null) {
                      context.pop(instance.lastErrorUserFriendly);
                    } else {
                      context.pop();
                    }
                  },
                ),
              OkButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      selectedShift != null &&
                      selectedStationState.singleSelectedStation != null) {
                    final selectedStationState =
                        context.read<SelectedStationsProvider>();
                    final datePickerState = context.read<DatePickerProvider>();
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
                        shift.id,
                      );
                    } else {
                      final date = datePickerState.reportDate;
                      result = await instance.createShiftData(
                        CreateShiftDataRequest(
                          station: selectedStationState.singleSelectedStation!,
                          shift: selectedShift!,
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
        },
      ),
    );
  }

  @override
  void dispose() {
    _inputPressureController.dispose();
    _outputPressureController.dispose();
    _inputTempController.dispose();
    _outputTempController.dispose();
    super.dispose();
  }
}
