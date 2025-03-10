import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/heplers.dart' as helpers;
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/stations_dropdown.dart';

class MainRoute extends StatefulWidget {
  static const routingName = "home";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;

  /// Creates a new Main route for the app.
  const MainRoute({super.key, this.fromDate, this.toDate, this.stationCodes});

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  Jalali? _fromDate;
  Jalali? _toDate;
  bool chip = false;

  int? _selectedStation;

  static final data = GetMonitoringFullReportResponse(
    count: 1,
    results: [
      GetMonitoringFullReportResponseResultItem(
        stationCode: 123,
        date: "1403-12-18",
        shifts: [
          Shift(
            inputPressure: 1,
            outputPressure: 2,
            inputTemperature: 3,
            outputTemperature: 4,
            registeredDatetime: "1403-12-18",
            user: "Me",
            shift: "06",
          ),
          Shift(
            inputPressure: 1,
            outputPressure: 2,
            inputTemperature: 3,
            outputTemperature: 4,
            registeredDatetime: "1403-12-18",
            user: "Me",
            shift: "08",
          ),
        ],
      ),
      GetMonitoringFullReportResponseResultItem(
        stationCode: 123,
        date: "1403-12-18",
        shifts: [
          Shift(
            inputPressure: 1,
            outputPressure: 2,
            inputTemperature: 3,
            outputTemperature: 4,
            registeredDatetime: "1403-12-18",
            user: "Me",
            shift: "06",
          ),
          Shift(
            inputPressure: 1,
            outputPressure: 2,
            inputTemperature: 3,
            outputTemperature: 4,
            registeredDatetime: "1403-12-18",
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
    final localResults = data.results.toList();

    if (_fromDate != null) {
      localResults.retainWhere((item) {
        final dateParts = item.date.split("-");
        final itemJalaliDate = Jalali(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
        return itemJalaliDate.isAfter(_fromDate!) ||
            itemJalaliDate.isAtSameMomentAs(_fromDate!);
      });
    }

    if (_toDate != null) {
      localResults.retainWhere((item) {
        final dateParts = item.date.split("-");
        final itemJalaliDate = Jalali(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
        return itemJalaliDate.isBefore(_toDate!) ||
            itemJalaliDate.isAtSameMomentAs(_toDate!);
      });
    }

    if (stationCode != null) {
      localResults.retainWhere((item) => item.stationCode == stationCode);
    }
    final value = GetMonitoringFullReportResponse(
      count: 1,
      results: localResults,
    );
    return value;
  }

  @override
  void initState() {
    super.initState();
    if (widget.fromDate != null) {
      final input = widget.fromDate!;
      final date = helpers.dashDateToJalali(input);
      if (date != null) {
        _fromDate = date;
        _fromDateController.text = _fromDate!.formatCompactDate();
      }
    }
    if (widget.toDate != null) {
      final input = widget.toDate!;
      final date = helpers.dashDateToJalali(input);
      if (date != null) {
        _toDate = date;
        _toDateController.text = _toDate!.formatCompactDate();
      }
    }
    if (widget.stationCodes != null) {
      final code = int.tryParse(widget.stationCodes!);
      _selectedStation = code;
    }
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
        final results = getData(_selectedStation);
        return SelectionArea(
          child: Scaffold(
            appBar: AppBar(title: Text("داشبورد"), centerTitle: true),
            drawer: MyDrawer(),
            body: SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  SizedBox(),
                  // Card(
                  //   color: Theme.of(context).colorScheme.inversePrimary,
                  //   elevation: 16,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(12.0),
                  //     child: Wrap(
                  //       spacing: 16,
                  //       children: [
                  //         FilterChip(
                  //           label: Text("سمنان"),
                  //           selected: chip,
                  //           onSelected: (value) {
                  //             setState(() {
                  //               chip = value;
                  //             });
                  //           },
                  //         ),
                  //         FilterChip(
                  //           label: Text("سمنان"),
                  //           selected: chip,
                  //           onSelected: (value) {
                  //             setState(() {
                  //               chip = value;
                  //             });
                  //           },
                  //         ),
                  //         FilterChip(
                  //           label: Text("سمنان"),
                  //           selected: chip,
                  //           onSelected: (value) {
                  //             setState(() {
                  //               chip = value;
                  //             });
                  //           },
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  StationsDropDown(
                    onSelected: (value) {
                      if (value == null) {
                        return;
                      }

                      if (value.contains("همه")) {
                        helpers.removeQueryFromPath(context, "stationCodes");
                        setState(() {
                          _selectedStation = null;
                        });
                        return;
                      }

                      final station = preferences.activeUser!.stations
                          .singleWhere((item) => item.code.contains(value));
                      _selectedStation = int.tryParse(station.code);
                      helpers.addQueryToPath(
                        context,
                        "stationCodes",
                        station.code,
                      );
                      setState(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Wrap(
                      spacing: 64,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            IconButton(
                              tooltip: "حذف فیلتر",
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              disabledColor: Colors.grey,
                              onPressed:
                                  _fromDate == null
                                      ? null
                                      : () {
                                        helpers.removeQueryFromPath(
                                          context,
                                          "fromDate",
                                        );
                                        setState(() {
                                          _fromDate = null;
                                          _fromDateController.clear();
                                        });
                                      },
                            ),
                            TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                constraints: BoxConstraints.loose(
                                  Size(300, double.infinity),
                                ),
                                labelText: "از تاریخ:",
                                hintText: "از تاریخ:",
                              ),
                              controller: _fromDateController,
                              onTap: () async {
                                final date = await showPersianDatePicker(
                                  context: context,
                                  locale: Preferences.persianLocale,
                                  firstDate: Jalali(1350),
                                  lastDate: Jalali.now(),
                                );
                                if (!context.mounted || date == null) return;
                                final queryString = helpers.jalaliToDashDate(
                                  date,
                                );
                                helpers.addQueryToPath(
                                  context,
                                  "fromDate",
                                  queryString,
                                );
                                setState(() {
                                  _fromDate = date;
                                  _fromDateController.text =
                                      _fromDate!.formatCompactDate();
                                });
                              },
                            ),
                          ],
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            IconButton(
                              tooltip: "حذف فیلتر",
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              disabledColor: Colors.grey,
                              onPressed:
                                  _toDate == null
                                      ? null
                                      : () {
                                        helpers.removeQueryFromPath(
                                          context,
                                          "toDate",
                                        );
                                        setState(() {
                                          _toDate = null;
                                          _toDateController.clear();
                                        });
                                      },
                            ),
                            TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                constraints: BoxConstraints.loose(
                                  Size(300, double.infinity),
                                ),
                                labelText: "تا تاریخ:",
                                hintText: "تا تاریخ:",
                              ),
                              controller: _toDateController,
                              onTap: () async {
                                final date = await showPersianDatePicker(
                                  context: context,
                                  locale: Preferences.persianLocale,
                                  firstDate: Jalali(1350),
                                  lastDate: Jalali.now(),
                                );
                                if (!context.mounted || date == null) return;
                                final queryString = helpers.jalaliToDashDate(
                                  date,
                                );
                                helpers.addQueryToPath(
                                  context,
                                  "toDate",
                                  queryString,
                                );
                                setState(() {
                                  _toDate = date;
                                  _toDateController.text =
                                      _toDate!.formatCompactDate();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: SizedBox(
                        width: 1500,
                        child: PaginatedDataTable(
                          headingRowColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.inversePrimary,
                          ),
                          rowsPerPage:
                              results.results.length <= 5 &&
                                      results.results.isNotEmpty
                                  ? results.results.length
                                  : 5,
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
                            getData(_selectedStation),
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

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
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
                                    Text(shift.registeredDatetime ?? ""),
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
