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
import 'package:tmms_shifts_client/providers/selected_ran_provider.dart';
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
import 'package:tmms_shifts_client/widgets/ran_radios_wrap.dart';
import 'package:tmms_shifts_client/widgets/single_station_selection_dropdown.dart';
import 'package:tmms_shifts_client/widgets/station_selection_field.dart';
import 'package:tmms_shifts_client/widgets/title_and_text_field_row.dart';
import 'package:tmms_shifts_client/widgets/vertical_horizontal_scrollable.dart';

class CorrectorReplacementEventsRoute extends StatefulWidget {
  static const routingName = "CorrectorReplacementEventsRoute";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;
  final String? sortBy;

  const CorrectorReplacementEventsRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
    this.sortBy,
  });

  @override
  State<CorrectorReplacementEventsRoute> createState() =>
      _CorrectorReplacementEventsRouteState();
}

class _CorrectorReplacementEventsRouteState
    extends State<CorrectorReplacementEventsRoute> {
  final _formKey = GlobalKey<FormState>();

  GetCorrectorChangeEventResponse? _currentlyEditingReport;

  final _oldMeterAmountController = TextEditingController();
  final _newMeterAmountController = TextEditingController();
  final _oldCorrectorAmountController = TextEditingController();
  final _newCorrectorAmountController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Helpers.initialRouteSetup(context);
  }

  Future<GetCorrectorChangeEventListResponse?> getCorrectorChangeEventReports(
    BuildContext context,
  ) async {
    final instance = NetworkInterface.instance();
    final result = await instance.getCorrectorChangeEventList(
      query: ToFromDateQuery(fromDate: widget.fromDate, toDate: widget.toDate),
    );
    return await Helpers.returnWithErrorIfNeeded(result);
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
        appBar: AppBar(title: Text(localizations.reportCorrectorChangeEvents)),
        drawer: const MyDrawer(),
        body: FutureBuilder(
          future: getCorrectorChangeEventReports(context),
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
                  NewReportButton(
                    onPressed: () async {
                      _currentlyEditingReport = null;
                      setupTextControllers();
                      selectedStationState.setSingleSelectedStation(null);
                      await Helpers.showEditDialogAndHandleResult(
                        context,
                        reportEditDialog(),
                      );
                    },
                  ),
                  ..._getCorrectorChangeEventCards(
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

  List<Widget> _getCorrectorChangeEventCards(
    BuildContext context,
    List<GetCorrectorChangeEventResponse> results,
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
          _currentlyEditingReport = item;

          final selectedStationState = context.read<SelectedStationsProvider>();
          setupTextControllers();
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
                      return DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.inversePrimary,
                        ),
                        columns: Helpers.getDataColumns(
                          context,
                          [
                            localizations.ranSequence,
                            localizations.ran,
                            localizations.oldMeterAmount,
                            localizations.newMeterAmount,
                            localizations.date,
                            localizations.registeredDate,
                            localizations.user,
                          ],
                          8,
                          210,
                        ),
                        rows: [
                          DataRow(
                            cells: Helpers.getDataCells([
                              item.ranSequence,
                              item.ran,
                              item.oldMeterAmount,
                              item.newMeterAmount,
                              Helpers.jalaliToDashDate(item.date),
                              Helpers.jalaliToDashDate(item.registeredDatetime),
                              item.user ?? "",
                            ]),
                          ),
                        ],
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

  Future<GetCorrectorChangeEventLastActionResponse>
  getCorrectorChangeEventLastAction(int stationCode) async {
    final instance = NetworkInterface.instance();
    final result = await instance.getCorrectorChangeEventLastAction(
      SingleStationQuery(stationCode),
    );
    return await Helpers.returnWithErrorIfNeeded(result);
  }

  Widget reportEditDialog() {
    final selectedStationState = context.read<SelectedStationsProvider>();
    final selectedRanState = context.read<SelectedRanProvider>();
    final datePickerState = context.read<DatePickerProvider>();
    final localizations = AppLocalizations.of(context)!;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: selectedStationState,
          key: const ObjectKey("Counter replacement dialog station provider"),
        ),
        ChangeNotifierProvider.value(
          value: selectedRanState,
          key: const ObjectKey("Counter replacement dialog ran provider"),
        ),
        ChangeNotifierProvider.value(
          value: datePickerState,
          key: const ObjectKey("Counter replacement dialog date provider"),
        ),
      ],
      child: Consumer<SelectedStationsProvider>(
        builder: (context, value, _) {
          // So that we can refresh it using the DataFetchError's refresh button
          // if needed.
          context.watch<Preferences>();

          final singleStation = selectedStationState.singleSelectedStation;

          FutureBuilder? lastActionFuture;
          if (singleStation != null) {
            lastActionFuture =
                FutureBuilder<GetCorrectorChangeEventLastActionResponse>(
                  future: getCorrectorChangeEventLastAction(singleStation),
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
                      final item = snapshot.data!;

                      return DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.inversePrimary,
                        ),
                        columns: Helpers.getDataColumns(
                          context,
                          [
                            localizations.ranSequence,
                            localizations.ran,
                            localizations.oldMeterAmount,
                            localizations.newMeterAmount,
                            localizations.date,
                            localizations.registeredDate,
                            localizations.user,
                          ],
                          8,
                          210,
                        ),
                        rows: [
                          DataRow(
                            cells: Helpers.getDataCells([
                              item.ranSequence,
                              item.ran,
                              item.oldMeterAmount,
                              item.newMeterAmount,
                              Helpers.jalaliToDashDate(item.date),
                              Helpers.jalaliToDashDate(item.registeredDatetime),
                              item.user ?? "",
                            ]),
                          ),
                        ],
                      );
                    }
                  },
                );
          }

          return AlertDialog(
            title: Text(localizations.newReport),
            content: SizedBox(
              width: 1500,
              height: 800,
              child: BothScrollable(
                child: SizedBox(
                  width: 1500,
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
                          Helpers.titleAndWidgetRow(
                            "${localizations.station}:",
                            const SingleStationSelectionDropdown(),
                          ),
                          const DatePickerSingleField(),
                          const RanRadiosWrap(),
                        ],
                        TitleAndTextFieldRow(
                          title: localizations.oldMeterAmount,
                          controller: _oldMeterAmountController,
                          numbersOnly: true,
                        ),
                        TitleAndTextFieldRow(
                          title: localizations.newMeterAmount,
                          controller: _newMeterAmountController,
                          numbersOnly: true,
                        ),
                        TitleAndTextFieldRow(
                          title: localizations.oldCorrectorAmount,
                          controller: _oldCorrectorAmountController,
                          numbersOnly: true,
                        ),
                        TitleAndTextFieldRow(
                          title: localizations.newCorrectorAmount,
                          controller: _newCorrectorAmountController,
                          numbersOnly: true,
                        ),
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
                    final result = await instance.deleteCorrectorChangeEvent(
                      _currentlyEditingReport!.id,
                    );

                    if (!context.mounted) return;
                    if (result == null) {
                      context.pop(instance.lastErrorUserFriendly);
                    } else {
                      context.pop();
                    }
                  },
                ),
              OkButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      selectedStationState.singleSelectedStation != null) {
                    final instance = NetworkInterface.instance();
                    final oldMeter = int.parse(_oldMeterAmountController.text);
                    final newMeter = int.parse(_newMeterAmountController.text);
                    final oldCorrector = int.parse(
                      _oldCorrectorAmountController.text,
                    );
                    final newCorrector = int.parse(
                      _newCorrectorAmountController.text,
                    );

                    final Object? result;

                    if (_currentlyEditingReport != null) {
                      final item = _currentlyEditingReport!;
                      result = await instance.updateCorrectorChangeEvent(
                        PutUpdateCorrectorChangeEventRequest(
                          id: item.id,
                          oldMeterAmount: oldMeter,
                          newMeterAmount: newMeter,
                          ran: item.ran,
                          date: item.date,
                          oldCorrectorAmount: oldCorrector,
                          newCorrectorAmount: newCorrector,
                          ranSequence: item.ranSequence,
                          user: item.user,
                          registeredDatetime: item.registeredDatetime,
                          stationCode: item.stationCode,
                        ),
                      );
                    } else {
                      final ran = selectedRanState.selectedRan;
                      final date = datePickerState.reportDate;
                      result = await instance.createCorrectorChangeEvent(
                        PostCreateCorrectorChangeEventRequest(
                          oldMeterAmount: oldMeter,
                          newMeterAmount: newMeter,
                          oldCorrectorAmount: oldCorrector,
                          newCorrectorAmount: newCorrector,
                          ran: ran,
                          date: date,
                        ),
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

  void setupTextControllers() {
    _oldMeterAmountController.text =
        _currentlyEditingReport?.oldMeterAmount.toString() ?? "";
    _newMeterAmountController.text =
        _currentlyEditingReport?.newMeterAmount.toString() ?? "";
    _oldCorrectorAmountController.text =
        _currentlyEditingReport?.oldCorrectorAmount.toString() ?? "";
    _newCorrectorAmountController.text =
        _currentlyEditingReport?.newCorrectorAmount.toString() ?? "";
  }

  @override
  void dispose() {
    _oldCorrectorAmountController.dispose();
    _newCorrectorAmountController.dispose();
    _oldMeterAmountController.dispose();
    _newMeterAmountController.dispose();
    super.dispose();
  }
}
