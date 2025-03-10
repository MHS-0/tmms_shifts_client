import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

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
