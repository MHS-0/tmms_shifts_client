import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/stations_dropdown.dart';

class MainRoute extends StatefulWidget {
  /// Creates a new Main route for the app.
  const MainRoute({super.key});

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  int? selectedStation;

  static final data = GetMonitoringFullReportResponse(
    count: 1,
    results: [
      GetMonitoringFullReportResponseResultItem(
        stationCode: 123,
        date: "1403-02-03",
        shifts: [
          Shift(
            inputPressure: 1,
            outputPressure: 2,
            inputTemperature: 3,
            outputTemperature: 4,
            registeredDatetime: "1403-02-03",
            user: "Me",
            shift: "06",
          ),
          Shift(
            inputPressure: 1,
            outputPressure: 2,
            inputTemperature: 3,
            outputTemperature: 4,
            registeredDatetime: "1403-02-03",
            user: "Me",
            shift: "08",
          ),
        ],
      ),
      GetMonitoringFullReportResponseResultItem(
        stationCode: 142,
        date: "1403-02-06",
        shifts: [
          Shift(
            inputPressure: 1,
            outputPressure: 2,
            inputTemperature: 3,
            outputTemperature: 4,
            registeredDatetime: "1403-02-06",
            user: "Me",
            shift: "03",
          ),
          Shift(
            inputPressure: 1,
            outputPressure: 2,
            inputTemperature: 3,
            outputTemperature: 4,
            registeredDatetime: "1403-02-06",
            user: "Me",
            shift: "02",
          ),
        ],
      ),
    ],
  );

  GetMonitoringFullReportResponse getData(int? stationCode) {
    if (stationCode != null) {
      final localResults = data.results.toList();
      localResults.retainWhere((item) => item.stationCode == stationCode);
      final value = GetMonitoringFullReportResponse(
        count: 1,
        results: localResults,
      );
      return value;
    }
    return data;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(iconAssetPath), context);
    precacheImage(const AssetImage(userIconAssetPath), context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null || user.stations.isEmpty) return Scaffold();

    return Consumer<Preferences>(
      builder: (_, preferences, __) {
        return SelectionArea(
          child: Scaffold(
            appBar: AppBar(title: Text("داشبورد"), centerTitle: true),
            drawer: MyDrawer(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 32),
                  StationsDropDown(
                    onSelected: (value) {
                      if (value == null || preferences.activeUser == null) {
                        return;
                      }
                      if (value.contains("همه")) {
                        setState(() {
                          selectedStation = null;
                        });
                        return;
                      }

                      final station = preferences.activeUser!.stations
                          .singleWhere((item) => item.code.contains(value));
                      setState(() {
                        selectedStation = int.tryParse(station.code);
                      });
                    },
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: SizedBox(
                        width: 1500,
                        child: PaginatedDataTable(
                          headingRowColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.inversePrimary,
                          ),
                          rowsPerPage: 5,
                          showEmptyRows: false,
                          dataRowMaxHeight: 100,
                          columns: [
                            DataColumn(
                              label: Text("ایستگاه"),
                              headingRowAlignment: MainAxisAlignment.center,
                              columnWidth: FlexColumnWidth(),
                            ),
                            DataColumn(
                              label: Text("تاریخ"),
                              headingRowAlignment: MainAxisAlignment.center,
                              columnWidth: FlexColumnWidth(),
                            ),
                            DataColumn(
                              label: Text("شیفت ها"),
                              headingRowAlignment: MainAxisAlignment.center,
                              columnWidth: FlexColumnWidth(),
                            ),
                            DataColumn(
                              label: Text("مصرف"),
                              headingRowAlignment: MainAxisAlignment.center,
                              columnWidth: FlexColumnWidth(),
                            ),
                            DataColumn(
                              label: Text("مصرف میانگین"),
                              headingRowAlignment: MainAxisAlignment.center,
                              columnWidth: FlexColumnWidth(),
                            ),
                          ],
                          source: MonitoringFullReportDataSource(
                            context,
                            localizations,
                            getData(selectedStation),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     showPersianDatePicker(
                  //       context: context,
                  //       firstDate: Jalali(1350),
                  //       lastDate: Jalali.now(),
                  //     );
                  //   },
                  //   child: Text("s"),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
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
                    return AlertDialog(
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
                                DataCell(Text(shift.inputPressure.toString())),
                                DataCell(Text(shift.outputPressure.toString())),
                                DataCell(
                                  Text(shift.inputTemperature.toString()),
                                ),
                                DataCell(
                                  Text(shift.outputTemperature.toString()),
                                ),
                                DataCell(Text(shift.registeredDatetime ?? "")),
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
          DataCell(Center(child: Text(data.results[index].date))),
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
