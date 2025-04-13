import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';

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
}
