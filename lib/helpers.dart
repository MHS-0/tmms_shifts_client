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
    context.goNamed(routeName, queryParameters: queries);
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
    context.goNamed(routeName, queryParameters: queries);
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

  static Future<String?> showCustomDialog(
    BuildContext context,
    Widget widget, {
    bool barrierDismissable = false,
  }) async {
    return await showDialog(
      barrierDismissible: barrierDismissable,
      context: context,
      builder: (context) {
        return widget;
      },
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
            create: (_) => SortProvider.fromQuery(sortBy),
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

  static Widget getExcelExportSortRow(List<Map<String, dynamic>> data) {
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
            child: ExcelExportButton(data: data),
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
    if (context.mounted && result != null) {
      await Helpers.showCustomDialog(
        context,
        ErrorAlertDialog(result),
        barrierDismissable: barrierDismissable,
      );
    } else if (context.mounted) {
      context.read<Preferences>().refreshRoute();
    }
  }
}
