import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/widgets/cancel_button.dart';
import 'package:tmms_shifts_client/widgets/data_fetch_error.dart';
import 'package:tmms_shifts_client/widgets/date_picker_row.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';
import 'package:tmms_shifts_client/widgets/excel_export_button.dart';
import 'package:tmms_shifts_client/widgets/ok_button.dart';
import 'package:tmms_shifts_client/widgets/single_station_selection_dropdown.dart';
import 'package:tmms_shifts_client/widgets/station_selection_field.dart';
import 'package:tmms_shifts_client/widgets/title_and_text_field_row.dart';

class CorrectorReplacementEventsRoute extends StatefulWidget {
  static const routingName = "CorrectorReplacementEventsRoute";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;

  const CorrectorReplacementEventsRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
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
  final _ranController = TextEditingController();

  final List<ScrollController> _mainScrollControllers = [];
  final List<ScrollController> _dialogScrollControllers = [];

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
    if (user == null || user.stations.isEmpty) return Scaffold();

    clearMainScrollControllers();
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.reportCounterChangeEvents)),
        drawer: const MyDrawer(),
        body: FutureBuilder(
          future: getCorrectorChangeEventReports(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DataFetchError(content: snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return centeredCircularProgressIndicator;
            } else {
              return ListView(
                padding: offsetAll16p,
                children: [
                  const SizedBox(),
                  const StationSelectionField(),
                  const DatePickerRow(),
                  ExcelExportButton(
                    data:
                        snapshot.data!.results.map((e) => e.toJson()).toList(),
                  ),
                  const SizedBox(height: 16),
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
                            setupTextControllers();
                            selectedStationState.setSingleSelectedStation(null);
                            await showEditDialogAndHandleResult(
                              context,
                              selectedStationState,
                              localizations,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  ..._getCorrectorChangeEventCards(
                    context,
                    snapshot.data!.results,
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
      final controller = ScrollController();
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

          await showEditDialogAndHandleResult(
            context,
            selectedStationState,
            localizations,
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
                Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: SingleChildScrollView(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
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
                                Helpers.jalaliToDashDate(
                                  item.registeredDatetime,
                                ),
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
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> showEditDialogAndHandleResult(
    BuildContext context,
    SelectedStationsProvider selectedStationState,
    AppLocalizations localizations,
  ) async {
    final String? result = await Helpers.showCustomDialog(
      context,
      reportEditDialog(selectedStationState, localizations),
      barrierDismissable: true,
    );
    clearDialogScrollControllers();
    if (context.mounted && result != null) {
      await Helpers.showCustomDialog(
        context,
        ErrorAlertDialog(result),
        barrierDismissable: true,
      );
    } else if (context.mounted) {
      context.read<Preferences>().refreshRoute();
    }
  }

  Future<GetMeterChangeEventLastActionResponse> getMeterChangeEventLastAction(
    int stationCode,
  ) async {
    final instance = NetworkInterface.instance();
    final result = await instance.getMeterChangeLastAction(
      SingleStationQuery(stationCode),
    );
    return await Helpers.returnWithErrorIfNeeded(result);
  }

  Widget reportEditDialog(
    SelectedStationsProvider selectedStationState,
    AppLocalizations localizations,
  ) {
    return ChangeNotifierProvider.value(
      value: selectedStationState,
      key: const ObjectKey("Counter replacement dialog provider"),
      child: Consumer<SelectedStationsProvider>(
        builder: (context, value, _) {
          clearDialogScrollControllers();
          final scrollController = ScrollController();
          _dialogScrollControllers.add(scrollController);

          // So that we can refresh it using the DataFetchError's refresh button
          // if needed.
          context.watch<Preferences>();

          final singleStation = selectedStationState.singleSelectedStation;

          FutureBuilder? lastActionFuture;
          if (singleStation != null) {
            lastActionFuture =
                FutureBuilder<GetMeterChangeEventLastActionResponse>(
                  future: getMeterChangeEventLastAction(singleStation),
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
              width: 1200,
              height: 800,
              child: SingleChildScrollView(
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: scrollController,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1200,
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
                            if (_currentlyEditingReport == null)
                              Helpers.titleAndWidgetRow(
                                localizations.station,
                                const SingleStationSelectionDropdown(),
                              ),
                            TitleAndTextFieldRow(
                              title: localizations.ran,
                              controller: _ranController,
                              numbersOnly: true,
                            ),
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
              ),
            ),
            actions: [
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
                    final ran = int.parse(_ranController.text);

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
                      result = await instance.createCorrectorChangeEvent(
                        PostCreateCorrectorChangeEventRequest(
                          oldMeterAmount: oldMeter,
                          newMeterAmount: newMeter,
                          oldCorrectorAmount: oldCorrector,
                          newCorrectorAmount: newCorrector,
                          ran: ran,
                          date: Jalali.now(),
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
    _ranController.text = _currentlyEditingReport?.ran.toString() ?? "";
  }

  void clearDialogScrollControllers() {
    for (final entry in _dialogScrollControllers) {
      entry.dispose();
    }
    _dialogScrollControllers.clear();
  }

  void clearMainScrollControllers() {
    for (final entry in _mainScrollControllers) {
      entry.dispose();
    }
    _mainScrollControllers.clear();
  }

  @override
  void dispose() {
    clearDialogScrollControllers();
    clearMainScrollControllers();
    _oldCorrectorAmountController.dispose();
    _newCorrectorAmountController.dispose();
    _oldMeterAmountController.dispose();
    _newMeterAmountController.dispose();
    _ranController.dispose();
    super.dispose();
  }
}
