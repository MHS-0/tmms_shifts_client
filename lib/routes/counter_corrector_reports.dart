import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/routes/counter_corrector_report_view.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';

const mockResults = GetMeterAndCorrectorFullReportResponse(
  count: 3,
  results: [
    GetMeterAndCorrectorFullReportResponseResultItem(
      stationCode: 123,
      date: "1403-12-18",
      user: "Ali",
      registeredDatetime: "1403-12-18",
      rans: [
        Ran2(
          meterAmount: 1,
          correctorAmount: 2,
          correctorMeterAmount: 3,
          ranSequence: 1,
          ran: 311410500000101,
        ),
        Ran2(
          meterAmount: 1,
          correctorAmount: 2,
          correctorMeterAmount: 3,
          ranSequence: 2,
          ran: 311410500000101,
        ),
        Ran2(
          meterAmount: 1,
          correctorAmount: 2,
          correctorMeterAmount: 3,
          ranSequence: 3,
          ran: 311410500000101,
        ),
      ],
    ),
    GetMeterAndCorrectorFullReportResponseResultItem(
      stationCode: 142,
      date: "1403-12-18",
      user: "Mammad",
      registeredDatetime: "1403-12-18",
      rans: [
        Ran2(
          meterAmount: 2,
          correctorAmount: 4,
          correctorMeterAmount: 6,
          ranSequence: 1,
          ran: 311410500000101,
        ),
        Ran2(
          meterAmount: 2,
          correctorAmount: 4,
          correctorMeterAmount: 6,
          ranSequence: 2,
          ran: 311410500000101,
        ),
        Ran2(
          meterAmount: 2,
          correctorAmount: 4,
          correctorMeterAmount: 6,
          ranSequence: 3,
          ran: 311410500000101,
        ),
      ],
    ),
    GetMeterAndCorrectorFullReportResponseResultItem(
      stationCode: 142,
      date: "1403-12-18",
      user: "Mammad",
      registeredDatetime: "1403-12-18",
      rans: [
        Ran2(
          meterAmount: 1,
          correctorAmount: 1,
          correctorMeterAmount: 1,
          ranSequence: 1,
          ran: 311410500000101,
        ),
        Ran2(
          meterAmount: 1,
          correctorAmount: 1,
          correctorMeterAmount: 1,
          ranSequence: 2,
          ran: 311410500000101,
        ),
        Ran2(
          meterAmount: 1,
          correctorAmount: 1,
          correctorMeterAmount: 1,
          ranSequence: 3,
          ran: 311410500000101,
        ),
      ],
    ),
  ],
);

class CounterCorrectorReportsRoute extends StatefulWidget {
  static const routingName = "CounterCorrectorReportsRoute";

  const CounterCorrectorReportsRoute({super.key});

  @override
  State<CounterCorrectorReportsRoute> createState() =>
      _CounterCorrectorReportsRouteState();
}

class _CounterCorrectorReportsRouteState
    extends State<CounterCorrectorReportsRoute> {
  GetMeterAndCorrectorFullReportResponse? reports;

  Future<GetMeterAndCorrectorFullReportResponse> getReports() async {
    await Future.delayed(Duration(seconds: 2));
    // final yesterdayString = (Jalali.now() - 1).toJalaliDateTime();
    return mockResults;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null || user.stations.isEmpty) return Scaffold();

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("گزارش کنتور و تصحیح کننده"),
          centerTitle: true,
        ),
        drawer: MyDrawer(),
        body: FutureBuilder(
          initialData: null,
          future: getReports(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              final data = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  spacing: 16,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: SizedBox(
                          width: 1500,
                          child: PaginatedDataTable(
                            showCheckboxColumn: false,
                            headingRowColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.inversePrimary,
                            ),
                            rowsPerPage:
                                data.results.length <= 5
                                    ? data.results.length
                                    : 5,
                            showEmptyRows: false,
                            dataRowMaxHeight: 100,
                            columns: [
                              DataColumn(
                                label: Text("کد ایستگاه"),
                                headingRowAlignment: MainAxisAlignment.center,
                                columnWidth: FlexColumnWidth(),
                              ),
                              DataColumn(
                                label: Text("تاریخ"),
                                headingRowAlignment: MainAxisAlignment.center,
                                columnWidth: FlexColumnWidth(),
                              ),
                              DataColumn(
                                label: Text("تاریخ ثبت"),
                                headingRowAlignment: MainAxisAlignment.center,
                                columnWidth: FlexColumnWidth(),
                              ),
                              DataColumn(
                                label: Text("کاربر"),
                                headingRowAlignment: MainAxisAlignment.center,
                                columnWidth: FlexColumnWidth(),
                              ),
                              DataColumn(
                                label: Text("Ran ها"),
                                headingRowAlignment: MainAxisAlignment.center,
                                columnWidth: FlexColumnWidth(),
                              ),
                            ],
                            source: CounterCorrectorReportsDataSource(
                              context,
                              localizations,
                              data,
                            ),
                          ),
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

class CounterCorrectorReportsDataSource extends DataTableSource {
  final GetMeterAndCorrectorFullReportResponse data;
  final BuildContext context;
  final AppLocalizations localizations;

  int? _selectedRow;

  CounterCorrectorReportsDataSource(
    this.context,
    this.localizations,
    this.data,
  );

  @override
  DataRow? getRow(int index) {
    if (index < data.results.length) {
      final DataCell ransDatacell;
      if (data.results[index].rans.isEmpty) {
        ransDatacell = DataCell(Text(""));
      } else {
        final List<Widget> ransWidgets = [];

        for (final ran in data.results[index].rans) {
          final title = "ran ${ran.ranSequence}";
          ransWidgets.addAll([
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
                              DataColumn(label: Text("مقدار کنتور")),
                              DataColumn(label: Text("مقدار تصحیح کننده")),
                              DataColumn(
                                label: Text("مقدار تصحیح کننده کنتور"),
                              ),
                              DataColumn(label: Text("ترتیب ران")),
                              DataColumn(label: Text("ران")),
                            ],
                            rows: [
                              DataRow(
                                cells: [
                                  DataCell(Text(ran.meterAmount.toString())),
                                  DataCell(
                                    Text(ran.correctorAmount.toString()),
                                  ),
                                  DataCell(
                                    Text(ran.correctorMeterAmount.toString()),
                                  ),
                                  DataCell(Text(ran.ranSequence.toString())),
                                  DataCell(Text(ran.ran.toString())),
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

        ransDatacell = DataCell(
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ransWidgets,
              ),
            ),
          ),
        );
      }
      return DataRow(
        selected: _selectedRow != null && _selectedRow == index,
        onSelectChanged: (selected) {
          if (selected == null) return;
          if (selected) {
            _selectedRow = index;
          } else {
            _selectedRow = null;
          }
          notifyListeners();
          context.goNamed(
            CounterCorrectorReportViewRoute.routingName,
            pathParameters: {"report": index.toString()},
          );
        },
        cells: [
          DataCell(Center(child: Text("${data.results[index].stationCode}"))),
          DataCell(Center(child: Text(data.results[index].date))),
          DataCell(
            Center(child: Text(data.results[index].registeredDatetime ?? "")),
          ),
          DataCell(Center(child: Text(data.results[index].user ?? ""))),
          ransDatacell,
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
  int get selectedRowCount => _selectedRow == null ? 0 : 1;
}
