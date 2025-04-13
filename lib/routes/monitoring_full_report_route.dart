import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/widgets/date_picker_row.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/station_selection_field.dart';

class MonitoringFullReportRoute extends StatefulWidget {
  static const routingName = "home";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;

  /// Creates a new Main route for the app.
  const MonitoringFullReportRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
  });

  @override
  State<MonitoringFullReportRoute> createState() =>
      _MonitoringFullReportRouteState();
}

class _MonitoringFullReportRouteState extends State<MonitoringFullReportRoute> {
  Future<GetMonitoringFullReportResponse> getData(BuildContext context) async {
    // FIXME: replace with network request in production.
    // final data = await NetworkInterface.instance().getMonitoringFullReport();

    if (!context.mounted) {
      return Future.error("context isn't mounted anymore");
    }

    final data = MockData.mockGetMonitoringFullReportResponse;
    final localResults = data.results.toList();

    final datePickerState = context.read<DatePickerProvider>();
    final fromDate = datePickerState.fromDate;
    final toDate = datePickerState.toDate;
    final selectedStations =
        context.read<SelectedStationsProvider>().selectedStations;

    if (fromDate != null) {
      localResults.retainWhere((item) {
        // final itemJalaliDate = helpers.dashDateToJalali(item.date);
        // if (itemJalaliDate == null) return true;

        final itemJalaliDate = item.date;
        return itemJalaliDate.isAfter(fromDate) ||
            itemJalaliDate.isAtSameMomentAs(fromDate);
      });
    }

    if (toDate != null) {
      localResults.retainWhere((item) {
        // final itemJalaliDate = helpers.dashDateToJalali(item.date);
        // if (itemJalaliDate == null) return true;

        final itemJalaliDate = item.date;
        return itemJalaliDate.isBefore(toDate) ||
            itemJalaliDate.isAtSameMomentAs(toDate);
      });
    }

    if (selectedStations.isNotEmpty) {
      localResults.retainWhere(
        (item) => selectedStations.contains(item.stationCode),
      );
    }
    final value = GetMonitoringFullReportResponse(
      count: 1,
      results: localResults,
    );
    return value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Helpers.initialRouteSetup(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null || user.stations.isEmpty) return Scaffold();

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.dashboard), centerTitle: true),
        drawer: MyDrawer(),
        body: FutureBuilder(
          future: getData(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return SingleChildScrollView(
                child: Column(
                  spacing: 16,
                  children: [
                    const SizedBox(),
                    const StationSelectionField(),
                    const DatePickerRow(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: SizedBox(
                          width: 1500,
                          // child: PaginatedDataTable(
                          //   headingRowColor: WidgetStatePropertyAll(
                          //     Theme.of(context).colorScheme.inversePrimary,
                          //   ),
                          //   rowsPerPage:
                          //       snapshot.data!.results.length <= 5 &&
                          //               snapshot.data!.results.isNotEmpty
                          //           ? snapshot.data!.results.length
                          //           : 5,
                          //   showEmptyRows: false,
                          //   dataRowMaxHeight: 100,
                          //   columns: [
                          //     DataColumn(
                          //       label: Text("ایستگاه"),
                          //       headingRowAlignment: MainAxisAlignment.center,
                          //       columnWidth: FlexColumnWidth(),
                          //     ),
                          //     DataColumn(
                          //       label: Text("تاریخ"),
                          //       headingRowAlignment: MainAxisAlignment.center,
                          //       columnWidth: FlexColumnWidth(),
                          //     ),
                          //     DataColumn(
                          //       label: Text("شیفت ها"),
                          //       headingRowAlignment: MainAxisAlignment.center,
                          //       columnWidth: FlexColumnWidth(),
                          //     ),
                          //     DataColumn(
                          //       label: Text("مصرف"),
                          //       headingRowAlignment: MainAxisAlignment.center,
                          //       columnWidth: FlexColumnWidth(),
                          //     ),
                          //     DataColumn(
                          //       label: Text("مصرف میانگین"),
                          //       headingRowAlignment: MainAxisAlignment.center,
                          //       columnWidth: FlexColumnWidth(),
                          //     ),
                          //   ],
                          //   source: MonitoringFullReportDataSource(
                          //     context,
                          //     localizations,
                          //     snapshot.data!,
                          //   ),
                          // ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class MonitoringFullReportDataSource extends DataTableSource {
  final GetMonitoringFullReportResponse data;
  final BuildContext context;
  final AppLocalizations localizations;

  MonitoringFullReportDataSource(this.context, this.localizations, this.data);

  @override
  DataRow? getRow(int index) {
    if (index < data.results.length) {
      final DataCell shiftsDatacell;
      if (data.results[index].shifts.isEmpty) {
        shiftsDatacell = DataCell(Text(""));
      } else {
        final List<Widget> shiftsWidgets = [];

        for (final shift in data.results[index].shifts) {
          final title = "شیفت ${shift.shift}";
          shiftsWidgets.addAll([
            InkWell(
              child: Text(
                title,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SelectionArea(
                      child: AlertDialog(
                        scrollable: true,
                        title: Text(title),
                        content: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text("فشار ورودی")),
                              DataColumn(label: Text("فشار خروجی")),
                              DataColumn(label: Text("دمای ورودی")),
                              DataColumn(label: Text("دمای خروجی")),
                              DataColumn(label: Text("زمان ثبت")),
                              DataColumn(label: Text("کاربر")),
                              DataColumn(label: Text("شیفت")),
                            ],
                            rows: [
                              DataRow(
                                cells: [
                                  DataCell(
                                    Text(shift.inputPressure.toString()),
                                  ),
                                  DataCell(
                                    Text(shift.outputPressure.toString()),
                                  ),
                                  DataCell(
                                    Text(shift.inputTemperature.toString()),
                                  ),
                                  DataCell(
                                    Text(shift.outputTemperature.toString()),
                                  ),
                                  DataCell(
                                    Text(
                                      shift.registeredDatetime
                                              ?.toJalaliDateTime() ??
                                          "",
                                    ),
                                  ),
                                  DataCell(Text(shift.user ?? "")),
                                  DataCell(Text(shift.shift)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            child: Text(localizations.okButtonText),
                            onPressed: () {
                              context.pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 8),
          ]);
        }

        shiftsDatacell = DataCell(
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: shiftsWidgets,
              ),
            ),
          ),
        );
      }
      return DataRow(
        cells: [
          DataCell(Center(child: Text("${data.results[index].stationCode}"))),
          DataCell(
            Center(child: Text(data.results[index].date.toJalaliDateTime())),
          ),
          shiftsDatacell,
          DataCell(
            Center(
              child: Text(data.results[index].consumption?.toString() ?? ""),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                data.results[index].averageConsumption?.toString() ?? "",
              ),
            ),
          ),
        ],
      );
    } else {
      return null;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.results.length;

  @override
  int get selectedRowCount => 0;
}
