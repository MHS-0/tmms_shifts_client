import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart' as helpers;
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/widgets/date_picker_row.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/station_selection_field.dart';

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

  // TODO: Make this neater.
  bool _readyToCallDatabase = false;
  int? selectedItemIndex;

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
                        selectedItemIndex = index;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          margin: EdgeInsets.all(8),
                          child: ExpansionTile(
                            onExpansionChanged: (_) {
                              selectedItemIndex = index;
                            },
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
                  ...cards,
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
