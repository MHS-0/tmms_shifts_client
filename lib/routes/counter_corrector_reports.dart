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

class CounterCorrectorReportsRoute extends StatefulWidget {
  static const routingName = "CounterCorrectorReportsRoute";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;
  final String? sortBy;

  const CounterCorrectorReportsRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
    this.sortBy,
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

  Future<GetMeterAndCorrectorFullReportResponse> getMeterAndCorrectorFullReport(
    BuildContext context,
  ) async {
    final instance = NetworkInterface.instance();
    final result = await instance.getMeterAndCorrectorFullReport(
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    Helpers.initialRouteSetup(context);
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
                      selectedStationState.setSingleSelectedStation(null);

                      await Helpers.showEditDialogAndHandleResult(
                        context,
                        reportEditDialog(),
                      );
                    },
                  ),
                  ..._getCounterCorrectorReportCards(context, results),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<GetCorrectorDataBulkLastActionResponse> getCorrectorLastAction(
    int stationCode,
  ) async {
    final instance = NetworkInterface.instance();
    final result = await instance.getCorrectorDataBulkLastAction(
      SingleStationQuery(stationCode),
    );
    return await Helpers.returnWithErrorIfNeeded(result);
  }

  Widget reportEditDialog() {
    final datePickerState = context.read<DatePickerProvider>();
    final localizations = AppLocalizations.of(context)!;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: context.read<SelectedStationsProvider>(),
          key: const ObjectKey("Counter And Corrector dialog station provider"),
        ),
        ChangeNotifierProvider.value(
          value: datePickerState,
          key: const ObjectKey("Counter And Corrector dialog date provider"),
        ),
      ],
      child: Builder(
        builder: (context) {
          final selectedStationState =
              context.watch<SelectedStationsProvider>();
          final user = context.watch<Preferences>().activeUser!;
          final title = Text(localizations.newReport);
          final singleStation = selectedStationState.singleSelectedStation;

          GetCorrectorDataBulkLastActionResponse? lastAction;

          FutureBuilder? lastActionFuture;
          if (singleStation != null) {
            lastActionFuture =
                FutureBuilder<GetCorrectorDataBulkLastActionResponse>(
                  future: getCorrectorLastAction(singleStation),
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
                      lastAction = snapshot.data;
                      return DataTable(
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
                                      Helpers.jalaliToDashDate(
                                        snapshot.data!.date,
                                      ),
                                      ran.ranSequence,
                                      ran.ran,
                                      ran.meterAmount,
                                      ran.correctorAmount,
                                    ]),
                                  ),
                                )
                                .toList(),
                      );
                    }
                  },
                );
          }

          final stationRans =
              user.stations
                  .where(
                    (e) => e.code == selectedStationState.singleSelectedStation,
                  )
                  .firstOrNull
                  ?.rans ??
              [];
          final List<Widget> ranWidgetsList = [];

          const meterTag = "Meter";
          const correctorTag = "Corrector";
          const correctorMeterTag = "CorrectorMeter";

          clearDialogControllers();
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
            final meterAmountController = TextEditingController(
              text: meterContent,
            );
            final correctorAmountController = TextEditingController(
              text: correctorContent,
            );
            final correctorMeterAmountController = TextEditingController(
              text: correctorMeterContent,
            );

            _textControllers.addAll([
              (ran.sequenceNumber, meterTag, meterAmountController),
              (ran.sequenceNumber, correctorTag, correctorAmountController),
              (
                ran.sequenceNumber,
                correctorMeterTag,
                correctorMeterAmountController,
              ),
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
          return AlertDialog(
            title: title,
            content: SizedBox(
              width: 900,
              child: BothScrollable(
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
                        if (lastActionFuture != null) ...[
                          Text(localizations.lastAction),
                          lastActionFuture,
                          SizedBox(),
                        ],
                        if (_currentlyEditingReport == null) ...[
                          const SingleStationSelectionDropdown(),
                          const DatePickerSingleField(center: true),
                        ],
                        ...ranWidgetsList,
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

                    for (final entry in _currentlyEditingReport!.rans) {
                      final result = await instance.deleteCorrectorData(
                        entry.id!,
                      );

                      if (!context.mounted) return;
                      if (result == null) {
                        context.pop(instance.lastErrorUserFriendly);
                        return;
                      }
                    }

                    context.pop();
                  },
                ),
              OkButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _textControllers.isNotEmpty) {
                    final selectedStationState =
                        context.read<SelectedStationsProvider>();
                    final user = context.read<Preferences>().activeUser!;

                    final List<Ran3> rans = [];
                    for (final ran in stationRans) {
                      final list =
                          _textControllers.where((e) {
                            return e.$1 == ran.sequenceNumber;
                          }).toList();

                      final meterAmount =
                          list.singleWhere((e) => e.$2 == meterTag).$3.text;
                      final correctorAmount =
                          list.singleWhere((e) => e.$2 == correctorTag).$3.text;
                      final correctorMeterAmount =
                          list
                              .singleWhere((e) => e.$2 == correctorMeterTag)
                              .$3
                              .text;
                      rans.add(
                        Ran3(
                          ran: ran.code.toString(),
                          meterAmount: meterAmount,
                          correctorAmount: correctorAmount,
                          correctorMeterAmount: correctorMeterAmount,
                        ),
                      );
                    }

                    final instance = NetworkInterface.instance();
                    final Object? result;
                    final Jalali date;
                    final Station? station;

                    if (_currentlyEditingReport != null) {
                      date = _currentlyEditingReport!.date;
                      station =
                          user.stations
                              .where(
                                (e) =>
                                    e.code ==
                                    _currentlyEditingReport!.stationCode,
                              )
                              .firstOrNull;
                    } else {
                      date = datePickerState.reportDate;
                      station =
                          user.stations
                              .where(
                                (e) =>
                                    e.code ==
                                    selectedStationState.singleSelectedStation,
                              )
                              .firstOrNull;
                    }

                    // TODO:
                    // Maybe add minDailyConsumption too?
                    if (lastAction != null &&
                        // Only show warning if last action is from at least 1 day in the past,
                        // otherwise, don't show it regardless.
                        // lastAction!.date.distanceFrom(date) > 0 &&
                        station != null &&
                        station.maxDailyConsumption != null) {
                      final action = lastAction!;
                      final dayDifference = date.distanceFrom(action.date);
                      int oldConsumption = 0;
                      int newConsumption = 0;

                      for (final entry in action.rans) {
                        oldConsumption += entry.correctorAmount;
                      }

                      for (final entry in rans) {
                        // FIXME???
                        // The text is *almost* guaranteed to be a correct number input,
                        // but framework bugs could happen at some point, so for now,
                        // add 0 if conversion to int fails.
                        newConsumption +=
                            int.tryParse(entry.correctorAmount) ?? 0;
                      }

                      if ((newConsumption - oldConsumption) >
                          (station.maxDailyConsumption! * dayDifference)) {
                        final String? result = await Helpers.showCustomDialog(
                          context,
                          AlertDialog(
                            title: Text(localizations.warning),
                            icon: const Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 40,
                            ),
                            content: Text(
                              localizations
                                  .inputDataInconsistentWithAverageData,
                            ),
                            actions: [
                              OkButton(
                                onPressed: () {
                                  context.pop("OK");
                                },
                              ),
                              const CancelButton(),
                            ],
                          ),
                        );

                        if (result != "OK") {
                          // Go back to the edit dialog without sending any data
                          return;
                        }
                        // Otherwise just continue from here and submit the user input data.
                      }
                    }

                    if (_currentlyEditingReport != null) {
                      result = await instance.putUpdateCorrectorBulk(
                        PutUpdateCorrectorBulkRequest(date: date, rans: rans),
                      );
                    } else {
                      result = await instance.createCorrectorBulk(
                        PostCreateCorrectorBulkRequest(date: date, rans: rans),
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

  List<Widget> _getCounterCorrectorReportCards(
    BuildContext context,
    List<GetMeterAndCorrectorFullReportResponseResultItem> results,
  ) {
    final user = context.read<Preferences>().activeUser!;
    final localizations = AppLocalizations.of(context)!;
    return results.map((item) {
      final stationOfItem =
          user.stations
              .where((entry) => entry.code == item.stationCode)
              .firstOrNull;

      return InkWell(
        onTap: () async {
          _currentlyEditingReport = item;
          final selectedStationState = context.read<SelectedStationsProvider>();
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
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void clearDialogControllers() {
    for (final entry in _textControllers) {
      entry.$3.dispose();
    }
    _textControllers.clear();
  }

  @override
  void dispose() {
    clearDialogControllers();
    super.dispose();
  }
}
