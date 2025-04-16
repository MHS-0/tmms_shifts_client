import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
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
import 'package:tmms_shifts_client/widgets/cancel_button.dart';
import 'package:tmms_shifts_client/widgets/data_fetch_error.dart';
import 'package:tmms_shifts_client/widgets/date_picker_row.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/ok_button.dart';
import 'package:tmms_shifts_client/widgets/single_station_selection_dropdown.dart';
import 'package:tmms_shifts_client/widgets/station_selection_field.dart';
import 'package:tmms_shifts_client/widgets/title_and_text_field_row.dart';

class CounterCorrectorReportsRoute extends StatefulWidget {
  static const routingName = "CounterCorrectorReportsRoute";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;

  const CounterCorrectorReportsRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
  });

  @override
  State<CounterCorrectorReportsRoute> createState() =>
      _CounterCorrectorReportsRouteState();
}

class _CounterCorrectorReportsRouteState
    extends State<CounterCorrectorReportsRoute> {
  final _formKey = GlobalKey<FormState>();

  GetMeterAndCorrectorFullReportResponseResultItem? _currentlyEditingReport;

  final List<(int, String, TextEditingController)> _textControllers = [];
  final List<ScrollController> _mainScrollControllers = [];
  final List<ScrollController> _dialogScrollControllers = [];

  Future<GetMeterAndCorrectorFullReportResponse> getMeterAndCorrectorFullReport(
    BuildContext context,
  ) async {
    final datePickerState = context.read<DatePickerProvider>();
    final selectedStationsState = context.read<SelectedStationsProvider>();
    final selectedStations = selectedStationsState.selectedStations;

    final String? fromDateParam;
    final String? toDateParam;
    {
      final fromDate = datePickerState.fromDate;
      final toDate = datePickerState.toDate;
      fromDateParam =
          fromDate != null ? Helpers.jalaliToDashDate(fromDate) : null;
      toDateParam = toDate != null ? Helpers.jalaliToDashDate(toDate) : null;
    }
    final GetMeterAndCorrectorFullReportResponse result;

    // FIXME: Replace with network implementation
    try {
      // result = await NetworkInterface.instance().getMeterAndCorrectorFullReport(
      //   query: ToFromDateStationsQuery(
      //     fromDate: fromDateParam,
      //     toDate: toDateParam,
      //     stationCodes: selectedStations,
      //   ),
      // );
      result = MockData.mockGetMeterAndCorrectorFullReportResponse;
    } catch (e) {
      return Future.error(e);
    }

    return result;
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
    final selectedStationState = context.watch<SelectedStationsProvider>();
    if (user == null || user.stations.isEmpty) return Scaffold();

    clearMainControllers();

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.meterAndCorrectorReports)),
        drawer: const MyDrawer(),
        body: FutureBuilder(
          future: getMeterAndCorrectorFullReport(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DataFetchError(content: snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return centeredCircularProgressIndicator;
            } else {
              final data = snapshot.data!;
              return ListView(
                padding: offsetAll16p,
                children: [
                  const SizedBox(),
                  const StationSelectionField(),
                  const DatePickerRow(),
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
                            selectedStationState.setSingleSelectedStation(null);

                            await Helpers.showCustomDialog(
                              context,
                              reportEditDialog(
                                user,
                                selectedStationState,
                                localizations,
                              ),
                              barrierDismissable: true,
                            );
                            // FIXME: Process stuff in prod.
                            clearDialogControllers();
                          },
                        ),
                      ),
                    ),
                  ),
                  ..._getCards(context, data.results, localizations, user),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<GetCorrectorDataBulkLastActionResponseListItem?>
  getCorrectorLastAction() async {
    // FIXME: replace in prod
    if (_currentlyEditingReport == null) {
      return GetCorrectorDataBulkLastActionResponseListItem(
        date: Jalali(1400),
        rans: [],
      );
    }
    await Future.delayed(Duration(seconds: 1));
    return MockData.mockGetCorrectorDataBulkLastAction.lastOrNull;
  }

  Widget reportEditDialog(
    ActiveUser user,
    SelectedStationsProvider selectedStationState,
    AppLocalizations localizations,
  ) {
    final stationRans =
        user.stations
            .where((e) => e.code == selectedStationState.singleSelectedStation)
            .firstOrNull
            ?.rans ??
        [];
    final List<Widget> ranWidgetsList = [];

    const meterTag = "Meter";
    const correctorTag = "Corrector";
    const correctorMeterTag = "CorrectorMeter";

    for (final ran in stationRans) {
      final String? meterContent =
          _currentlyEditingReport?.rans
              .where((e) => e.ranSequence == ran.sequenceNumber)
              .firstOrNull
              ?.meterAmount
              .toString();
      final String? correctorContent =
          _currentlyEditingReport?.rans
              .where((e) => e.ranSequence == ran.sequenceNumber)
              .firstOrNull
              ?.correctorAmount
              .toString();
      final String? correctorMeterContent =
          _currentlyEditingReport?.rans
              .where((e) => e.ranSequence == ran.sequenceNumber)
              .firstOrNull
              ?.correctorMeterAmount
              .toString();
      final meterAmountController = TextEditingController(text: meterContent);
      final correctorAmountController = TextEditingController(
        text: correctorContent,
      );
      final correctorMeterAmountController = TextEditingController(
        text: correctorMeterContent,
      );

      _textControllers.addAll([
        (ran.sequenceNumber, meterTag, meterAmountController),
        (ran.sequenceNumber, correctorTag, correctorAmountController),
        (ran.sequenceNumber, correctorMeterTag, correctorMeterAmountController),
      ]);

      ranWidgetsList.addAll([
        SizedBox(height: 16),
        Text(
          "${localizations.ran} ${ran.sequenceNumber}",
          style: boldTextStyle,
        ),
        TitleAndTextFieldRow(
          title: localizations.meterAmount,
          controller: meterAmountController,
          numbersOnly: true,
        ),
        TitleAndTextFieldRow(
          title: localizations.correctorAmount,
          controller: correctorAmountController,
          numbersOnly: true,
        ),
        TitleAndTextFieldRow(
          title: localizations.correctorMeterAmount,
          controller: correctorMeterAmountController,
          numbersOnly: true,
        ),
      ]);
    }

    return ChangeNotifierProvider.value(
      value: selectedStationState,
      key: const ObjectKey("Counter And Corrector dialog provider"),
      child: FutureBuilder(
        future: getCorrectorLastAction(),
        builder: (context, snapshot) {
          final title = Text(localizations.newReport);
          if (snapshot.hasError) {
            return AlertDialog(
              title: title,
              content: DataFetchError(content: snapshot.error.toString()),
            );
          } else if (!snapshot.hasData) {
            return AlertDialog(
              title: title,
              content: SizedBox(
                height: 500,
                width: 1200,
                child: centeredCircularProgressIndicator,
              ),
            );
          } else {
            final scrollController = ScrollController();
            _dialogScrollControllers.add(scrollController);

            final lastActionTable = DataTable(
              headingRowColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.inversePrimary,
              ),
              columns: Helpers.getDataColumns(
                context,
                [
                  localizations.date,
                  localizations.ranSequence,
                  localizations.ran,
                  localizations.meterAmount,
                  localizations.correctorAmount,
                ],
                6,
                175,
              ),
              rows:
                  snapshot.data!.rans
                      .map<DataRow>(
                        (ran) => DataRow(
                          cells: Helpers.getDataCells([
                            Helpers.jalaliToDashDate(snapshot.data!.date),
                            ran.ranSequence,
                            ran.ran,
                            ran.meterAmount,
                            ran.correctionAmount,
                          ]),
                        ),
                      )
                      .toList(),
            );
            return Consumer<SelectedStationsProvider>(
              builder: (context, value, _) {
                return AlertDialog(
                  title: title,
                  content: SizedBox(
                    width: 900,
                    height: 500,
                    child: SingleChildScrollView(
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: scrollController,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 900,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 16,
                                children: [
                                  if (selectedStationState
                                          .singleSelectedStation !=
                                      null) ...[
                                    Text(localizations.lastAction),
                                    lastActionTable,
                                  ],
                                  const SingleStationSelectionDropdown(),
                                  ...ranWidgetsList,
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
                        // FIXME: Do network call here in production.
                        if (_formKey.currentState!.validate()) {
                          context.pop();
                        }
                      },
                    ),
                    const CancelButton(),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  DataTable getCounterCorrectorReportDataTable(
    BuildContext context,
    AppLocalizations localizations,
    GetMeterAndCorrectorFullReportResponseResultItem item,
  ) {
    return DataTable(
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.inversePrimary,
      ),
      columns: Helpers.getDataColumns(
        context,
        [
          localizations.ranSequence,
          localizations.ran,
          localizations.meterAmount,
          localizations.correctorAmount,
          localizations.correctorMeterAmount,
        ],
        6,
        250,
      ),
      rows:
          item.rans
              .map<DataRow>(
                (ran) => DataRow(
                  cells: Helpers.getDataCells([
                    ran.ranSequence,
                    ran.ran,
                    ran.meterAmount,
                    ran.correctorAmount,
                    ran.correctorMeterAmount,
                  ]),
                ),
              )
              .toList(),
    );
  }

  List<Widget> _getCards(
    BuildContext context,
    List<GetMeterAndCorrectorFullReportResponseResultItem> results,
    AppLocalizations localizations,
    ActiveUser user,
  ) {
    return results.map((item) {
      final scrollController = ScrollController();
      _mainScrollControllers.add(scrollController);

      return InkWell(
        onTap: () {
          _currentlyEditingReport = item;
          final selectedStationState = context.read<SelectedStationsProvider>();
          selectedStationState.setSingleSelectedStation(item.stationCode);
          Helpers.showCustomDialog(
            context,
            reportEditDialog(user, selectedStationState, localizations),
            barrierDismissable: true,
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
                  Text(
                    '${localizations.station}: ${user.stations.where((entry) => entry.code == item.stationCode).firstOrNull?.title ?? ""}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${localizations.date}: ${dateFormatter.format(DateTime.parse(item.date.toJalaliDateTime()))}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${localizations.stationCode}: ${item.stationCode}'),
                ],
              ),
              children: [
                Scrollbar(
                  thumbVisibility: true,
                  controller: scrollController,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = MediaQuery.of(context).size.width;
                        // if (width >= 1200) {
                        return getCounterCorrectorReportDataTable(
                          context,
                          localizations,
                          item,
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

  void clearDialogControllers() {
    for (final value in _textControllers) {
      value.$3.dispose();
    }
    _textControllers.clear();

    for (final value in _dialogScrollControllers) {
      value.dispose();
    }
    _dialogScrollControllers.clear();
  }

  void clearMainControllers() {
    for (final entry in _mainScrollControllers) {
      entry.dispose();
    }
    _mainScrollControllers.clear();
  }

  @override
  void dispose() {
    clearDialogControllers();
    clearMainControllers();
    super.dispose();
  }
}
