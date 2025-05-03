import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_ran_provider.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/providers/sort_provider.dart';
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';
import 'package:tmms_shifts_client/widgets/excel_export_button.dart';
import 'package:tmms_shifts_client/widgets/sort_selector.dart';

final class Helpers {
  /// Remove a query from the current path shown in the Browser's
  /// address bar.
  static void removeQueryFromPath(BuildContext context, String name) {
    final routerState = GoRouter.of(context).state;
    final Map<String, dynamic> queries = Map.from(
      routerState.uri.queryParameters,
    );
    queries.remove(name);
    final routeName = routerState.name!;
    context.replaceNamed(routeName, queryParameters: queries);
  }

  /// Add a query to the current path shown in the Browser's
  /// address bar.
  static void addQueryToPath(BuildContext context, String name, String value) {
    final routerState = GoRouter.of(context).state;
    final Map<String, dynamic> queries = Map.from(
      routerState.uri.queryParameters,
    );
    queries[name] = value;
    final routeName = routerState.name!;
    context.replaceNamed(routeName, queryParameters: queries);
  }

  /// Convert from a [Jalali] class to a formatted string
  /// like: "1404-08-02"
  static String jalaliToDashDate(Jalali date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  /// Convert from an string with a format such as 1404-08-02 to
  /// a [Jalali] class.
  static Jalali? dashDateToJalali(String dashDate) {
    final items = dashDate.split("-");
    if (items.length == 3) {
      final year = int.tryParse(items[0]);
      final month = int.tryParse(items[1]);
      final day = int.tryParse(items[2]);

      if (year != null && month != null && day != null) {
        return Jalali(year, month, day);
      }
    }
    return null;
  }

  /// Convert from an string with a format such as 1404-08-02 to
  /// a [Jalali] class.
  static Jalali dashDateToJalaliNonNull(String dashDate) {
    return Helpers.dashDateToJalali(dashDate)!;
  }

  static DatePickerProvider getDatePickerProviderFromQueries(
    String? fromDate,
    String? toDate,
  ) {
    Jalali? fromDateParam;
    Jalali? toDateParam;

    if (fromDate != null) {
      final input = fromDate;
      final date = dashDateToJalali(input);
      fromDateParam = date;
    }
    if (toDate != null) {
      final input = toDate;
      final date = dashDateToJalali(input);
      toDateParam = date;
    }

    return DatePickerProvider(
      fromDateParam: fromDateParam,
      toDateParam: toDateParam,
    );
  }

  static SelectedStationsProvider getSelectedStationsProviderFromQueries(
    String? stationCodes,
  ) {
    List<int> selectedStationsParam = [];

    if (stationCodes != null) {
      final stations = stationCodes.split(",");
      for (final station in stations) {
        final code = int.tryParse(station);
        if (code != null) {
          selectedStationsParam.add(code);
        } else {
          continue;
        }
      }
    }

    return SelectedStationsProvider(
      selectedStationsParam: selectedStationsParam,
    );
  }

  /// Precache images and icons, etc.
  /// Should be called in didChangeDependencies
  static void initialRouteSetup(BuildContext context) {
    precacheImage(iconAssetImage, context);
    precacheImage(userIconAssetImage, context);
  }

  /// Deserialize ISO 8601 formatted string into a Jalali instance
  /// example of correct input: "1403-02-02 08:30:32"
  static Jalali parseJalaliFromIso8601(String json) {
    final date = DateTime.parse(json.trim()).toLocal();
    return Jalali(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
    );
  }

  static Jalali? parseJalaliFromIso8601NullAware(String? json) {
    if (json == null) return null;

    final date = DateTime.parse(json.trim()).toLocal();
    return Jalali(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
    );
  }

  /// Serialize a Jalali instance into an ISO 8601 formatted String
  /// example of output: "1403-02-02 08:30:32"
  static String serializeJalaliIntoIso8601(Jalali dateTime) =>
      dateTime.toJalaliDateTime();

  static String? serializeJalaliIntoIso8601NullAware(Jalali? dateTime) =>
      dateTime?.toJalaliDateTime();

  /// Serialize a list of integers into an string. Used for queries.
  /// Example: [1234, 4532] ==> "1234,4532"
  static String? serializeIntListIntoCommaSeperatedString(List<int>? list) {
    if (list == null || list.isEmpty) {
      return null;
    } else {
      return list.join(",");
    }
  }

  /// Serialize a comma seperated String of numbers into a List\<int\>. Used for queries.
  /// Example: "1234,4532" ==> [1234, 4532]
  static List<int> serializeStringIntoIntList(String? input) {
    if (input == null) return [];

    final output =
        input.split(",").map((e) {
          final result = int.tryParse(e);
          if (result == null) return -1;
          return result;
        }).toList();

    output.removeWhere((e) => e == -1);
    return output;
  }

  static Future<T?> showCustomDialog<T>(
    BuildContext context,
    Widget widget, {
    bool barrierDismissable = false,
  }) async {
    return await showDialog(
      barrierDismissible: barrierDismissable,
      context: context,
      builder: (_) => widget,
    );
  }

  static List<DataColumn> getDataColumns(
    BuildContext context,
    List<String> labels,
    double divisionNumber,
    double minimumWidth,
  ) {
    // unused for now. needs more testing.
    final maxWidthAvailable = MediaQuery.of(context).size.width;
    final List<DataColumn> result = [];

    for (final label in labels) {
      result.add(
        DataColumn(
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // columnWidth: MaxColumnWidth(
          //   FixedColumnWidth(maxWidthAvailable / divisionNumber),
          //   FixedColumnWidth(minimumWidth),
          // ),
          columnWidth: FixedColumnWidth(minimumWidth),
        ),
      );
    }
    return result;
  }

  static List<DataCell> getDataCells(List<Object> contents) {
    final List<DataCell> result = [];
    for (final entry in contents) {
      result.add(DataCell(Text("$entry")));
    }
    return result;
  }

  static Future<void> showNetworkErrorAlertDialog(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    final netInterface = NetworkInterface.instance();
    await Helpers.showCustomDialog(
      context,
      ErrorAlertDialog(netInterface.lastErrorUserFriendly),
      barrierDismissable: true,
    );
    return;
  }

  static MaterialPage materialPageWithMultiProviders(
    GoRouterState state,
    Widget route,
    String routingName, {
    bool ranProvider = false,
  }) {
    final queries = state.uri.queryParameters;
    final stationCodes = queries[stationCodesKey];
    final fromDate = queries[fromDateKey];
    final toDate = queries[toDateKey];
    final sortBy = queries[sortByKey];
    final customSortId = queries[customSortKey];

    return MaterialPage(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create:
                (_) => Helpers.getSelectedStationsProviderFromQueries(
                  stationCodes,
                ),
            key: ObjectKey("$routingName SelectedStationProvider"),
          ),
          ChangeNotifierProvider(
            create:
                (_) =>
                    Helpers.getDatePickerProviderFromQueries(fromDate, toDate),
            key: ObjectKey("$routingName DatePickerProvider"),
          ),
          ChangeNotifierProvider(
            create: (_) => SortProvider.fromQuery(sortBy, customSortId),
            key: ObjectKey("$routingName SortProvider"),
          ),
          if (ranProvider)
            ChangeNotifierProvider(
              create: (_) => SelectedRanProvider(),
              key: ObjectKey("$routingName SelectedRanProvider"),
            ),
        ],
        child: route,
      ),
    );
  }

  // TODO: Refactor & Clean up
  static Future<T> returnWithErrorIfNeeded<T>(T? value) async {
    final instance = NetworkInterface.instance();
    if (value == null) {
      return Future.error(instance.lastErrorUserFriendly);
    } else {
      return value;
    }
  }

  static Row cardTitleDetailsRow(List<String> children, [bool bold = false]) {
    final List<Widget> widgets = [];

    for (final entry in children) {
      widgets.add(
        Expanded(
          child: Center(child: Text(entry, style: bold ? boldTextStyle : null)),
        ),
      );
    }

    return Row(children: widgets);
  }

  static Text boldText(String content) {
    return Text(content, style: boldTextStyle);
  }

  static Widget titleAndWidgetRow(
    String title,
    Widget widget, {
    double width = 400,
    bool center = false,
    double titleWidth = 200,
  }) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment:
            center ? MainAxisAlignment.center : MainAxisAlignment.start,
        spacing: 32,
        children: [
          SizedBox(
            width: titleWidth,
            child: Align(
              alignment: center ? Alignment.center : Alignment.centerLeft,
              child: Text(
                title,
                textAlign: TextAlign.end,
                style: titleRowTextStyle,
              ),
            ),
          ),
          SizedBox(width: width, child: widget),
        ],
      ),
    );
  }

  static Future<Uint8List> exportToExcelBytesForMonitoring(
    List<GetMonitoringFullReportResponseResultItem> data,
    List<Station> stations,
    AppLocalizations localizations,
  ) async {
    try {
      var excel = Excel.createExcel();
      final Sheet sheet = excel['Sheet1'];

      if (data.isEmpty) {
        return Future.error(localizations.dataIsEmpty);
      }

      List<String> headers = [
        localizations.stationName,
        localizations.date,
        localizations.outOfService,
        localizations.inputPressureAt6,
        localizations.outputPressureAt6,
        localizations.inputTempAt6,
        localizations.outputTempAt6,
        localizations.inputPressureAt12,
        localizations.outputPressureAt12,
        localizations.inputTempAt12,
        localizations.outputTempAt12,
        localizations.inputPressureAt18,
        localizations.outputPressureAt18,
        localizations.inputTempAt18,
        localizations.outputTempAt18,
        localizations.inputPressureAt24,
        localizations.outputPressureAt24,
        localizations.inputTempAt24,
        localizations.outputTempAt24,
        localizations.gasConsumptionM2,
        localizations.gasConsumptionAverageM2,
      ];
      for (final header in headers.indexed) {
        final headerCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: header.$1, rowIndex: 0),
        );
        headerCell.value = TextCellValue(header.$2);
        headerCell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blueAccent,
        );
      }

      for (final value in data.indexed) {
        final rowData = value.$2;
        final station =
            stations.where((e) => e.code == value.$2.stationCode).firstOrNull;
        if (station != null) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 0,
                  rowIndex: value.$1 + 1,
                ),
              )
              .value = TextCellValue("${station.typeName} | ${station.title}");
        }

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 1,
                rowIndex: value.$1 + 1,
              ),
            )
            .value = TextCellValue(value.$2.date.toJalaliDateTime());

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 2,
                rowIndex: value.$1 + 1,
              ),
            )
            .value = BoolCellValue(false);
        for (int i = 0; i < 4; i++) {
          final shift =
              rowData.shifts
                  .where((e) => e.shift == ((i * 6) + 6).toString())
                  .firstOrNull;
          if (shift == null) continue;

          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 3 + (i * 4),
                  rowIndex: value.$1 + 1,
                ),
              )
              .value = IntCellValue(shift.inputPressure);
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 4 + (i * 4),
                  rowIndex: value.$1 + 1,
                ),
              )
              .value = IntCellValue(shift.outputPressure);
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 5 + (i * 4),
                  rowIndex: value.$1 + 1,
                ),
              )
              .value = IntCellValue(shift.inputTemperature);
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 6 + (i * 4),
                  rowIndex: value.$1 + 1,
                ),
              )
              .value = IntCellValue(shift.outputTemperature);
        }

        final consumption = rowData.consumption;
        final averageConsumption = rowData.averageConsumption;

        if (consumption != null) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 19,
                  rowIndex: value.$1 + 1,
                ),
              )
              .value = IntCellValue(consumption);
        }

        if (averageConsumption != null) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 20,
                  rowIndex: value.$1 + 1,
                ),
              )
              .value = IntCellValue(averageConsumption);
        }
      }

      final List<int>? fileBytes = excel.encode();

      if (fileBytes == null) {
        return Future.error(localizations.dataEncodeError);
      }

      return Uint8List.fromList(fileBytes);
    } catch (e) {
      return Future.error("${localizations.dataEncodeError}:\n$e");
    }
  }

  static Future<Uint8List> exportToExcelBytes(
    List<Map<String, dynamic>> data,
    AppLocalizations localizations,
  ) async {
    try {
      var excel = Excel.createExcel();
      final Sheet sheet = excel['Sheet1'];

      if (data.isEmpty) {
        return Future.error(localizations.dataIsEmpty);
      }

      List<String> headers = data.first.keys.toList();
      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0),
            )
            .value = TextCellValue(headers[colIndex]);
      }

      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final Map<String, dynamic> rowData = data[rowIndex];
        for (int colIndex = 0; colIndex < headers.length; colIndex++) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: colIndex,
                  rowIndex: rowIndex + 1,
                ),
              )
              .value = TextCellValue(rowData[headers[colIndex]].toString());
        }
      }

      final List<int>? fileBytes = excel.encode();

      if (fileBytes == null) {
        return Future.error(localizations.dataEncodeError);
      }

      return Uint8List.fromList(fileBytes);
    } catch (e) {
      return Future.error("${localizations.dataEncodeError}:\n$e");
    }
  }

  static Widget getExcelExportSortRow(
    List<Object?> data,
    List<Station> stations, {
    bool isMonitoring = false,
  }) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 550,
          child: Align(alignment: Alignment.centerRight, child: SortSelector()),
        ),
        SizedBox(
          width: 300,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ExcelExportButton(
              data: data,
              stations: stations,
              isMonitoring: isMonitoring,
            ),
          ),
        ),
      ],
    );
  }

  static Map<int, String> getStationCodeTitleMap(
    List<int> codes,
    List<Station> stations,
  ) {
    final Map<int, String> stationCodeToTitleMap = {};
    for (final entry in codes) {
      if (stationCodeToTitleMap.containsKey(entry)) {
        continue;
      }
      stationCodeToTitleMap[entry] =
          stations.where((e) => e.code == entry).firstOrNull?.title ?? "";
    }
    return stationCodeToTitleMap;
  }

  // FIXME
  // TODO
  // Definitely refactor this into something cleaner!
  static List<T> sortResults<T>(
    SortProvider state,
    List<Station> stations,
    List<T> initial,
  ) {
    List<GetPressureAndTemperatureFullReportResponseResultItem>?
    pressureAndTempList;
    List<GetMonitoringFullReportResponseResultItem>? monitoringList;
    List<GetMeterAndCorrectorFullReportResponseResultItem>? meterCorrectorList;
    List<GetMeterChangeEventResponse>? meterChangeList;
    List<GetCorrectorChangeEventResponse>? correctorChangeList;

    Map<int, String> stationCodeTitleMap;

    if (T == GetPressureAndTemperatureFullReportResponseResultItem) {
      pressureAndTempList =
          initial
              as List<GetPressureAndTemperatureFullReportResponseResultItem>;
      stationCodeTitleMap = Helpers.getStationCodeTitleMap(
        pressureAndTempList.map((e) => e.stationCode).toList(),
        stations,
      );
    } else if (T == GetMonitoringFullReportResponseResultItem) {
      monitoringList =
          initial as List<GetMonitoringFullReportResponseResultItem>;
      stationCodeTitleMap = Helpers.getStationCodeTitleMap(
        monitoringList.map((e) => e.stationCode).toList(),
        stations,
      );
    } else if (T == GetMeterAndCorrectorFullReportResponseResultItem) {
      meterCorrectorList =
          initial as List<GetMeterAndCorrectorFullReportResponseResultItem>;
      stationCodeTitleMap = Helpers.getStationCodeTitleMap(
        meterCorrectorList.map((e) => e.stationCode).toList(),
        stations,
      );
    } else if (T == GetMeterChangeEventResponse) {
      meterChangeList = initial as List<GetMeterChangeEventResponse>;
      stationCodeTitleMap = Helpers.getStationCodeTitleMap(
        meterChangeList.map((e) => e.stationCode).toList(),
        stations,
      );
    } else if (T == GetCorrectorChangeEventResponse) {
      correctorChangeList = initial as List<GetCorrectorChangeEventResponse>;
      stationCodeTitleMap = Helpers.getStationCodeTitleMap(
        correctorChangeList.map((e) => e.stationCode).toList(),
        stations,
      );
    } else {
      sharedLogger.log(
        Level.SEVERE,
        "Failed to sort list, returning empty list",
      );
      return [];
    }

    switch (state.selectedSort) {
      case SortSelection.byDateAsc:
        pressureAndTempList?.sort(
          (a, b) => a.date.julianDayNumber.compareTo(b.date.julianDayNumber),
        );
        monitoringList?.sort(
          (a, b) => a.date.julianDayNumber.compareTo(b.date.julianDayNumber),
        );
        meterCorrectorList?.sort(
          (a, b) => a.date.julianDayNumber.compareTo(b.date.julianDayNumber),
        );
        meterChangeList?.sort(
          (a, b) => a.date.julianDayNumber.compareTo(b.date.julianDayNumber),
        );
        correctorChangeList?.sort(
          (a, b) => a.date.julianDayNumber.compareTo(b.date.julianDayNumber),
        );
        break;
      case SortSelection.byStationAlphabeticAsc:
        pressureAndTempList?.sort(
          (a, b) => stationCodeTitleMap[a.stationCode]!.compareTo(
            stationCodeTitleMap[b.stationCode]!,
          ),
        );
        monitoringList?.sort(
          (a, b) => stationCodeTitleMap[a.stationCode]!.compareTo(
            stationCodeTitleMap[b.stationCode]!,
          ),
        );
        meterCorrectorList?.sort(
          (a, b) => stationCodeTitleMap[a.stationCode]!.compareTo(
            stationCodeTitleMap[b.stationCode]!,
          ),
        );
        meterChangeList?.sort(
          (a, b) => stationCodeTitleMap[a.stationCode]!.compareTo(
            stationCodeTitleMap[b.stationCode]!,
          ),
        );
        correctorChangeList?.sort(
          (a, b) => stationCodeTitleMap[a.stationCode]!.compareTo(
            stationCodeTitleMap[b.stationCode]!,
          ),
        );
        break;
      case SortSelection.byStationAlphabeticDesc:
        pressureAndTempList?.sort(
          (a, b) => stationCodeTitleMap[b.stationCode]!.compareTo(
            stationCodeTitleMap[a.stationCode]!,
          ),
        );
        monitoringList?.sort(
          (a, b) => stationCodeTitleMap[b.stationCode]!.compareTo(
            stationCodeTitleMap[a.stationCode]!,
          ),
        );
        meterCorrectorList?.sort(
          (a, b) => stationCodeTitleMap[b.stationCode]!.compareTo(
            stationCodeTitleMap[a.stationCode]!,
          ),
        );
        meterChangeList?.sort(
          (a, b) => stationCodeTitleMap[b.stationCode]!.compareTo(
            stationCodeTitleMap[a.stationCode]!,
          ),
        );
        correctorChangeList?.sort(
          (a, b) => stationCodeTitleMap[b.stationCode]!.compareTo(
            stationCodeTitleMap[a.stationCode]!,
          ),
        );
        break;
      default:
        pressureAndTempList?.sort(
          (a, b) => b.date.julianDayNumber.compareTo(a.date.julianDayNumber),
        );
        monitoringList?.sort(
          (a, b) => b.date.julianDayNumber.compareTo(a.date.julianDayNumber),
        );
        meterCorrectorList?.sort(
          (a, b) => b.date.julianDayNumber.compareTo(a.date.julianDayNumber),
        );
        meterChangeList?.sort(
          (a, b) => b.date.julianDayNumber.compareTo(a.date.julianDayNumber),
        );
        correctorChangeList?.sort(
          (a, b) => b.date.julianDayNumber.compareTo(a.date.julianDayNumber),
        );
        break;
    }

    if (state.selectedCustomSort != null) {
      final sortList = state.selectedCustomSort!;
      final userCustomSortList =
          Preferences.instance().activeUser?.customStationSort
              ?.where((e) => e.id == sortList)
              .firstOrNull
              ?.stations;

      userCustomSortList?.sort((a, b) => a.priority.compareTo(b.priority));
      if (userCustomSortList == null) return [];

      // FIXME: Maybe a better algorithm can be used?
      // TODO:
      final List<GetMonitoringFullReportResponseResultItem>
      orderedMonitoringList = [];

      for (final entry in userCustomSortList) {
        orderedMonitoringList.addAll(
          monitoringList?.where((e) => e.stationCode == entry.station) ?? [],
        );
        monitoringList?.removeWhere((e) => e.stationCode == entry.station);
      }
      orderedMonitoringList.addAll(monitoringList ?? []);
      monitoringList = orderedMonitoringList;

      // monitoringList?.sort((a, b) {
      //   final aPriority =
      //       userCustomSortList
      //           .where((e) => e.station == a.stationCode)
      //           .firstOrNull
      //           ?.priority;
      //   final bPriority =
      //       userCustomSortList
      //           .where((e) => e.station == b.stationCode)
      //           .firstOrNull
      //           ?.priority;

      //   if (aPriority != null && bPriority != null) {
      //     print(8);
      //     return aPriority.compareTo(bPriority);
      //   }
      //   if (aPriority != null) return aPriority;
      //   if (bPriority != null) return bPriority;

      //   // else, put at the bottom of the sorted list.
      //   return 99999;
      // });
    }

    if (pressureAndTempList != null) return pressureAndTempList as List<T>;
    if (monitoringList != null) return monitoringList as List<T>;
    if (meterCorrectorList != null) return meterCorrectorList as List<T>;
    if (meterChangeList != null) return meterChangeList as List<T>;
    if (correctorChangeList != null) return correctorChangeList as List<T>;
    sharedLogger.log(Level.SEVERE, "Invalid state");
    return [];
  }

  static Future<void> showEditDialogAndHandleResult(
    BuildContext context,
    Widget dialog, {
    bool barrierDismissable = true,
  }) async {
    context.read<DatePickerProvider>().setReportDate(Jalali.now());
    final String? result = await Helpers.showCustomDialog(
      context,
      dialog,
      barrierDismissable: barrierDismissable,
    );
    if (!context.mounted) return;
    if (result != null && result != cancelledMessage) {
      await Helpers.showCustomDialog(
        context,
        ErrorAlertDialog(result),
        barrierDismissable: barrierDismissable,
      );
    } else if (result == null) {
      context.read<Preferences>().refreshRoute();
    }
  }

  static Widget getStationGroupSelectionField(
    BuildContext context, [
    bool noneInsteadOfNew = true,
  ]) {
    final user = context.read<Preferences>().activeUser!;
    final sortState = context.read<SortProvider>();
    final selectedSort = sortState.selectedCustomSort;
    final localizations = AppLocalizations.of(context)!;
    final entries =
        user.customStationSort?.map((item) {
          final thisSortIsSelected =
              (selectedSort != null && selectedSort == item.id);

          return DropdownMenuEntry(
            value: item.id,
            label: item.title,
            leadingIcon:
                thisSortIsSelected ? selectedCheckIcon : unselectedCheckIcon,
            labelWidget:
                thisSortIsSelected ? Helpers.boldText(item.title) : null,
          );
        }).toList();

    final selectionField = DropdownMenu<int?>(
      initialSelection: selectedSort,
      onSelected: (sort) {
        if (selectedSort == sort) return;
        sortState.setSelectedCustomSort(
          user.customStationSort?.where((e) => e.id == sort).firstOrNull?.id,
        );
        if (sort == null) {
          Helpers.removeQueryFromPath(context, customSortKey);
        } else {
          Helpers.addQueryToPath(context, customSortKey, sort.toString());
        }
      },
      width: 300,
      hintText: localizations.customSort,
      dropdownMenuEntries: [
        DropdownMenuEntry(
          value: null,
          label:
              noneInsteadOfNew ? localizations.none : localizations.newReport,
        ),
        if (entries != null) ...entries,
      ],
    );

    return selectionField;
  }
}
