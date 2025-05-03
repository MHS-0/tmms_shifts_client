import 'package:flutter/material.dart';
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
import 'package:tmms_shifts_client/widgets/data_fetch_future_builder.dart';
import 'package:tmms_shifts_client/widgets/date_picker_row.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/horizontal_scrollable.dart';
import 'package:tmms_shifts_client/widgets/new_report_button.dart';
import 'package:tmms_shifts_client/widgets/pressure_and_temp_report_edit_dialog.dart';
import 'package:tmms_shifts_client/widgets/station_selection_field.dart';

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
    if (user == null || user.stations.isEmpty) return Scaffold();

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.reportPressureAndTemp)),
        drawer: const MyDrawer(),
        body: DataFetchFutureBuilder(
          future: getPressureAndTempReports(context),
          builder: (context, data) {
            final results = data.results;

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
          final selectedStationState = context.read<SelectedStationsProvider>();
          selectedStationState.setSingleSelectedStation(item.stationCode);

          await Helpers.showEditDialogAndHandleResult(
            context,
            reportEditDialog(item),
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

  Widget reportEditDialog([
    GetPressureAndTemperatureFullReportResponseResultItem? item,
  ]) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: context.read<SelectedStationsProvider>(),
          key: const ObjectKey("Pressure and temp dialog station provider"),
        ),
        ChangeNotifierProvider.value(
          value: context.read<DatePickerProvider>(),
          key: const ObjectKey("Pressure and temp dialog date provider"),
        ),
      ],
      child: Builder(
        builder: (_) => PressureAndTempReportEditDialog(entry: item),
      ),
    );
  }
}
