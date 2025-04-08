import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart' as helpers;
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/widgets/date_picker_row.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
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
  static final dateFormatterWithHour = DateFormat("HH:mm yyyy-MM-dd");
  static final dateFormatter = DateFormat("dd-MM-yyyy");

  final _formKey = GlobalKey<FormState>();

  // TODO: Make this neater.
  bool _readyToCallDatabase = false;
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

    _readyToCallDatabase = false;
    helpers.initialRouteSetup(
      context,
      fromDate: widget.fromDate,
      toDate: widget.toDate,
      stationCodes: widget.stationCodes,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readyToCallDatabase = true;
    });
  }

  Future<GetPressureAndTemperatureFullReportResponse> getPressureAndTempReports(
    BuildContext context,
  ) async {
    // FIXME: Replace with network implementation

    // await Future.delayed(Duration(seconds: 2));

    while (!_readyToCallDatabase) {
      await Future.delayed(Duration(milliseconds: 50));
    }

    if (!context.mounted) {
      return Future.error("context isn't mounted anymore");
    }

    final data = MockData.mockGetPressureAndTemperatureFullReportResponse;
    final localResults = data.results.toList();

    final datePickerState = context.read<DatePickerProvider>();
    final fromDate = datePickerState.fromDate;
    final toDate = datePickerState.toDate;
    final selectedStations =
        context.read<SelectedStationsProvider>().selectedStations;

    if (fromDate != null) {
      localResults.retainWhere((item) {
        final itemJalaliDate = helpers.dashDateToJalali(item.date);
        if (itemJalaliDate == null) return true;

        return itemJalaliDate.isAfter(fromDate) ||
            itemJalaliDate.isAtSameMomentAs(fromDate);
      });
    }

    if (toDate != null) {
      localResults.retainWhere((item) {
        final itemJalaliDate = helpers.dashDateToJalali(item.date);
        if (itemJalaliDate == null) return true;
        return itemJalaliDate.isBefore(toDate) ||
            itemJalaliDate.isAtSameMomentAs(toDate);
      });
    }

    if (selectedStations.isNotEmpty) {
      localResults.retainWhere(
        (item) => selectedStations.contains(item.stationCode),
      );
    }
    final value = GetPressureAndTemperatureFullReportResponse(
      count: 1,
      results: localResults,
    );
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null || user.stations.isEmpty) return Scaffold();

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.reportPressureAndTemp),
          centerTitle: true,
        ),
        drawer: MyDrawer(),
        body: FutureBuilder(
          future: getPressureAndTempReports(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              final results = snapshot.data!.results;

              final cards =
                  results.indexed.map((entry) {
                    final index = entry.$1;
                    final item = entry.$2;

                    return InkWell(
                      onTap: () {
                        _currentlyEditingReport = item;
                        if (item.shifts.isNotEmpty) {
                          selectedShift = item.shifts.first.shift;
                        } else {
                          selectedShift = "06";
                        }
                        final selectedStationState =
                            context.read<SelectedStationsProvider>();
                        selectedStationState.setSingleSelectedStation(
                          item.stationCode,
                        );
                        setupTextControllers();
                        setState(() {});

                        showDialog(
                          context: context,
                          builder: (context) {
                            return reportEditDialog(
                              selectedStationState,
                              localizations,
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          margin: EdgeInsets.all(8),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            title: Text(
                              '${localizations.stationCode}: ${item.stationCode}\n\n${localizations.date}: ${dateFormatter.format(DateTime.parse(item.date))}\n',
                            ),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: 1400,
                                  child: DataTable(
                                    headingRowColor: WidgetStatePropertyAll(
                                      Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                                    ),
                                    columns: [
                                      DataColumn(
                                        label: Text(localizations.shift),
                                        columnWidth: FlexColumnWidth(),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          localizations.inputPressure,
                                        ),
                                        columnWidth: FlexColumnWidth(),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          localizations.outputPressure,
                                        ),
                                        columnWidth: FlexColumnWidth(),
                                      ),
                                      DataColumn(
                                        label: Text(localizations.inputTemp),
                                        columnWidth: FlexColumnWidth(),
                                      ),
                                      DataColumn(
                                        label: Text(localizations.outputTemp),
                                        columnWidth: FlexColumnWidth(),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          localizations.registeredDate,
                                        ),
                                        columnWidth: FlexColumnWidth(),
                                      ),
                                      DataColumn(
                                        label: Text(localizations.user),
                                        columnWidth: FlexColumnWidth(),
                                      ),
                                    ],
                                    rows:
                                        item.shifts
                                            .map<DataRow>(
                                              (shift) => DataRow(
                                                cells: [
                                                  DataCell(Text(shift.shift)),
                                                  DataCell(
                                                    Text(
                                                      shift.inputPressure
                                                          .toString(),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      shift.outputPressure
                                                          .toString(),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      shift.inputTemperature
                                                          .toString(),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      shift.outputTemperature
                                                          .toString(),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      shift.registeredDatetime !=
                                                              null
                                                          ? dateFormatterWithHour
                                                              .format(
                                                                DateTime.parse(
                                                                  shift
                                                                      .registeredDatetime!,
                                                                ),
                                                              )
                                                          : "",
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(shift.user ?? ""),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(),
                  const StationSelectionField(),
                  const DatePickerRow(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 50,
                            child: FilledButton(
                              onPressed: () async {
                                _currentlyEditingReport = null;
                                selectedShift = null;
                                final selectedStationState =
                                    context.read<SelectedStationsProvider>();
                                selectedStationState.setSingleSelectedStation(
                                  null,
                                );
                                setupTextControllers();
                                setState(() {});

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return reportEditDialog(
                                      selectedStationState,
                                      localizations,
                                    );
                                  },
                                );
                              },
                              child: Row(
                                spacing: 16,
                                children: [
                                  Text(localizations.newReport),
                                  Icon(Icons.add),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...cards,
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void setupTextControllers() {
    if (_currentlyEditingReport != null && selectedShift != null) {
      final localShift = _currentlyEditingReport!.shifts.where(
        (item) => item.shift.contains(selectedShift!),
      );
      if (localShift.isNotEmpty) {
        final entry = localShift.first;
        _inputPressureController.text = entry.inputPressure.toString();
        _outputPressureController.text = entry.outputPressure.toString();
        _inputTempController.text = entry.inputTemperature.toString();
        _outputTempController.text = entry.outputTemperature.toString();
      }
    } else {
      _inputPressureController.clear();
      _outputPressureController.clear();
      _inputTempController.clear();
      _outputTempController.clear();
    }
  }

  Widget reportEditDialog(
    SelectedStationsProvider selectedStationState,
    AppLocalizations localizations,
  ) {
    return ChangeNotifierProvider.value(
      value: selectedStationState,
      child: AlertDialog(
        title: Text(localizations.newReport),
        content: SizedBox(
          width: 800,
          height: 500,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      SingleStationSelectionDropdown(),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // FIXME: Replace with network request.
              if (_formKey.currentState != null &&
                  _formKey.currentState!.validate()) {
                context.pop();
              }
            },
            child: Text(localizations.okButtonText),
          ),
          FilledButton(
            child: Text(localizations.cancelButtonText),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
