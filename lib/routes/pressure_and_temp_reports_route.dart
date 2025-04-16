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

class PressureAndTempReportsRoute extends StatefulWidget {
  static const routingName = "pressure_and_temp_reports_route";

  final String? fromDate;
  final String? toDate;
  final String? stationCodes;

  const PressureAndTempReportsRoute({
    super.key,
    this.fromDate,
    this.toDate,
    this.stationCodes,
  });

  @override
  State<PressureAndTempReportsRoute> createState() =>
      _PressureAndTempReportsRouteState();
}

class _PressureAndTempReportsRouteState
    extends State<PressureAndTempReportsRoute> {
  final _formKey = GlobalKey<FormState>();

  String? selectedShift;
  GetPressureAndTemperatureFullReportResponseResultItem?
  _currentlyEditingReport;

  final _inputPressureController = TextEditingController();
  final _outputPressureController = TextEditingController();
  final _inputTempController = TextEditingController();
  final _outputTempController = TextEditingController();

  final List<ScrollController> _mainScrollControllers = [];
  final List<ScrollController> _dialogScrollControllers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Helpers.initialRouteSetup(context);
  }

  Future<GetPressureAndTemperatureFullReportResponse> getPressureAndTempReports(
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
    final GetPressureAndTemperatureFullReportResponse result;

    // FIXME: Replace with network implementation
    // try {
    //   result = await NetworkInterface.instance()
    //       .getPressureAndTemperatureFullReport(
    //         query: ToFromDateStationsQuery(
    //           fromDate: fromDateParam,
    //           toDate: toDateParam,
    //           stationCodes: selectedStations,
    //         ),
    //       );
    // } catch (e) {
    //   return Future.error(e);
    // }
    result = MockData.mockGetPressureAndTemperatureFullReportResponse;

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.watch<Preferences>().activeUser;
    final selectedStationState = context.watch<SelectedStationsProvider>();
    if (user == null || user.stations.isEmpty) return Scaffold();

    clearMainScrollControllers();

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.reportPressureAndTemp)),
        drawer: const MyDrawer(),
        body: FutureBuilder(
          future: getPressureAndTempReports(context),
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
                            selectedShift = null;
                            setupTextControllers();
                            selectedStationState.setSingleSelectedStation(null);

                            await Helpers.showCustomDialog(
                              context,
                              reportEditDialog(
                                selectedStationState,
                                localizations,
                              ),
                              barrierDismissable: true,
                            );
                            clearDialogScrollControllers();
                          },
                        ),
                      ),
                    ),
                  ),
                  ..._getCards(
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

  List<Widget> _getCards(
    BuildContext context,
    List<GetPressureAndTemperatureFullReportResponseResultItem> results,
    AppLocalizations localizations,
    ActiveUser user,
  ) {
    return results.map((item) {
      final controller = ScrollController();

      return InkWell(
        onTap: () async {
          _currentlyEditingReport = item;
          selectedShift = item.shifts.firstOrNull?.shift ?? "06";

          final selectedStationState = context.read<SelectedStationsProvider>();
          setupTextControllers();
          selectedStationState.setSingleSelectedStation(item.stationCode);

          await Helpers.showCustomDialog(
            context,
            reportEditDialog(selectedStationState, localizations),
            barrierDismissable: true,
          );
          clearDialogScrollControllers();
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
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void setupTextControllers() {
    Shift? shift;
    if (selectedShift != null) {
      shift =
          _currentlyEditingReport?.shifts
              .where((item) => item.shift.contains(selectedShift!))
              .firstOrNull;
    }
    _inputPressureController.text = shift?.inputPressure.toString() ?? "";
    _outputPressureController.text = shift?.outputPressure.toString() ?? "";
    _inputTempController.text = shift?.inputTemperature.toString() ?? "";
    _outputTempController.text = shift?.outputTemperature.toString() ?? "";
  }

  Widget reportEditDialog(
    SelectedStationsProvider selectedStationState,
    AppLocalizations localizations,
  ) {
    final scrollController = ScrollController();
    _dialogScrollControllers.add(scrollController);

    return ChangeNotifierProvider.value(
      value: selectedStationState,
      key: const ObjectKey("Pressure and temp dialog provider"),
      child: AlertDialog(
        title: Text(localizations.newReport),
        content: SizedBox(
          width: 800,
          height: 600,
          child: SingleChildScrollView(
            child: Scrollbar(
              thumbVisibility: true,
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 800,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        const SingleStationSelectionDropdown(),
                        DropdownMenu(
                          initialSelection: selectedShift,
                          onSelected: (shift) {
                            if (shift == null) return;

                            selectedShift = shift;
                            setupTextControllers();
                            setState(() {});
                          },
                          width: 300,
                          hintText: localizations.shift,
                          dropdownMenuEntries:
                              ["06", "12", "18", "24"].map((entry) {
                                return DropdownMenuEntry(
                                  value: entry,
                                  label: entry,
                                );
                              }).toList(),
                        ),
                        TitleAndTextFieldRow(
                          title: localizations.inputPressure,
                          controller: _inputPressureController,
                          numbersOnly: true,
                        ),
                        TitleAndTextFieldRow(
                          title: localizations.outputPressure,
                          controller: _outputPressureController,
                          numbersOnly: true,
                        ),
                        TitleAndTextFieldRow(
                          title: localizations.inputTemp,
                          controller: _inputTempController,
                          numbersOnly: true,
                        ),
                        TitleAndTextFieldRow(
                          title: localizations.outputTemp,
                          controller: _outputTempController,
                          numbersOnly: true,
                        ),
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
      ),
    );
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
    _inputPressureController.dispose();
    _outputPressureController.dispose();
    _inputTempController.dispose();
    _outputTempController.dispose();
    super.dispose();
  }
}
