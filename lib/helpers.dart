import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';

/// Remove a query from the current path shown in the Browser's
/// address bar.
void removeQueryFromPath(BuildContext context, String name) {
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
void addQueryToPath(BuildContext context, String name, String value) {
  final routerState = GoRouter.of(context).state;
  final Map<String, dynamic> queries = Map.from(
    routerState.uri.queryParameters,
  );
  queries[name] = value;
  final routeName = routerState.name!;
  context.goNamed(routeName, queryParameters: queries);
}

/// Convert from a [Jalali] class to a formatted string
/// like: "1404/08/02"
String jalaliToDashDate(Jalali date) {
  return "${date.year}-${date.month}-${date.day}";
}

/// Convert from an string with a format such as 1404/08/02 to
/// a [Jalali] class.
Jalali? dashDateToJalali(String dashDate) {
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

/// Precache images and icons, process query strings, etc.
/// Should be called in didChangeDependencies
void initialRouteSetup(
  BuildContext context, {
  String? fromDate,
  String? toDate,
  String? stationCodes,
}) {
  precacheImage(iconAssetImage, context);
  precacheImage(userIconAssetImage, context);

  final datePickerState = context.read<DatePickerProvider>();
  final selectedStationsState = context.read<SelectedStationsProvider>();

  // Reset everything and start over.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    datePickerState.setFromDate(null);
    datePickerState.setToDate(null);
    selectedStationsState.clearStations();
  });

  if (fromDate != null) {
    final input = fromDate;
    final date = dashDateToJalali(input);
    if (date != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        datePickerState.setFromDate(date);
      });
    }
  }
  if (toDate != null) {
    final input = toDate;
    final date = dashDateToJalali(input);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      datePickerState.setToDate(date);
    });
  }
  if (stationCodes != null) {
    final stations = stationCodes.split(",");
    for (final station in stations) {
      final code = int.tryParse(station);
      if (code != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          selectedStationsState.addStation(code);
        });
      } else {
        continue;
      }
    }
  }
}
