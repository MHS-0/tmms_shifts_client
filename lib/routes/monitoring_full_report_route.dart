import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/sort_provider.dart';
import 'package:tmms_shifts_client/widgets/data_fetch_error.dart';
import 'package:tmms_shifts_client/widgets/date_picker_row.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/horizontal_scrollable.dart';
import 'package:tmms_shifts_client/widgets/station_selection_field.dart';

class MonitoringFullReportRoute extends StatefulWidget {
  static const routingName = "home";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;
  final String? sortBy;

  /// Creates a new home route for the app.
  const MonitoringFullReportRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
    this.sortBy,
  });

  @override
  State<MonitoringFullReportRoute> createState() =>
      _MonitoringFullReportRouteState();
}

class _MonitoringFullReportRouteState extends State<MonitoringFullReportRoute> {
  Future<GetMonitoringFullReportResponse> getData(BuildContext context) async {
    final instance = NetworkInterface.instance();
    final result = await instance.getMonitoringFullReport(
      query: ToFromDateStationsQuery(
        fromDate: widget.fromDate,
        toDate: widget.toDate,
        stationCodes: Helpers.serializeStringIntoIntList(widget.stationCodes),
      ),
    );
    return await Helpers.returnWithErrorIfNeeded(result);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Helpers.initialRouteSetup(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.watch<Preferences>().activeUser;
    final sortState = context.read<SortProvider>();
    if (user == null || user.stations.isEmpty) return Scaffold();

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.dashboard)),
        drawer: const MyDrawer(),
        body: FutureBuilder(
          future: getData(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DataFetchError(content: snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return centeredCircularProgressIndicator;
            } else {
              final results = Helpers.sortResults(
                sortState,
                user.stations,
                snapshot.data!.results,
              );
              return ListView(
                padding: offsetAll16p,
                children: [
                  const SizedBox(),
                  const StationSelectionField(),
                  const DatePickerRow(),
                  Helpers.getExcelExportSortRow(
                    results.map((e) => e.toJson()).toList(),
                  ),
                  const SizedBox(height: 16),
                  ..._getMonitoringFullReportCards(
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

  List<Widget> _getMonitoringFullReportCards(
    BuildContext context,
    List<GetMonitoringFullReportResponseResultItem> results,
    AppLocalizations localizations,
    ActiveUser user,
  ) {
    return results.map((item) {
      final stationOfItem =
          user.stations
              .where((entry) => entry.code == item.stationCode)
              .firstOrNull;

      return Padding(
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
                  '${localizations.consumption}: ${item.consumption ?? ""}',
                  '${localizations.averageConsumption}: ${item.averageConsumption ?? ""}',
                ], true),
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
      );
    }).toList();
  }
}
