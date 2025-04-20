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
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';

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
    String routingName,
  ) {
    final queries = state.uri.queryParameters;
    final stationCodes = queries[stationCodesKey];
    final fromDate = queries[fromDateKey];
    final toDate = queries[toDateKey];

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

  static Widget titleAndWidgetRow(String title, Widget widget) {
    return SizedBox(
      height: 80,
      child: Row(
        spacing: 32,
        children: [
          SizedBox(
            width: 200,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                textAlign: TextAlign.end,
                style: titleRowTextStyle,
              ),
            ),
          ),
          SizedBox(width: 400, child: widget),
        ],
      ),
    );
  }

  static Future<Uint8List> exportToExcelBytes(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      var excel = Excel.createExcel();
      final Sheet sheet = excel['Sheet1'];

      if (data.isEmpty) {
        sharedLogger.log(Level.WARNING, "Empty data");
        return Uint8List(0);
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
        // Failure.
        // FIXME: handle better. maybe a dialog.
        sharedLogger.log(Level.WARNING, "Failed to encode data");
        return Uint8List(0);
      }

      return Uint8List.fromList(fileBytes);
    } catch (e) {
      // Faliure
      // FIXME: handle better. maybe a dialog.
      sharedLogger.log(Level.WARNING, "Failed to encode data: $e");
      return Uint8List(0);
    }
  }
}
