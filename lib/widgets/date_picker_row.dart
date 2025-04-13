import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

class DatePickerRow extends StatefulWidget {
  const DatePickerRow({super.key});

  @override
  State<DatePickerRow> createState() => _DatePickerRowState();
}

class _DatePickerRowState extends State<DatePickerRow> {
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final fromDate = context.read<DatePickerProvider>().fromDate;
    final toDate = context.read<DatePickerProvider>().toDate;

    if (fromDate != null) {
      _fromDateController.text = fromDate.formatCompactDate();
    }
    if (toDate != null) {
      _toDateController.text = toDate.formatCompactDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final fromDate = context.read<DatePickerProvider>().fromDate;
    final toDate = context.read<DatePickerProvider>().toDate;

    if (fromDate == null) {
      _fromDateController.clear();
    } else {
      _fromDateController.text = fromDate.formatCompactDate();
    }

    if (toDate == null) {
      _toDateController.clear();
    } else {
      _toDateController.text = toDate.formatCompactDate();
    }

    return Consumer<DatePickerProvider>(
      builder: (context, value, _) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Wrap(
              spacing: 64,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: localizations.removeFilter,
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      disabledColor: Colors.grey,
                      onPressed:
                          fromDate == null
                              ? null
                              : () {
                                Helpers.removeQueryFromPath(
                                  context,
                                  "fromDate",
                                );
                                value.setFromDate(null);
                                setState(() {});
                              },
                    ),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        constraints: BoxConstraints.loose(
                          Size(300, double.infinity),
                        ),
                        labelText: localizations.fromDate,
                        hintText: localizations.fromDate,
                      ),
                      controller: _fromDateController,
                      onTap: () async {
                        final date = await showPersianDatePicker(
                          context: context,
                          locale: Preferences.persianIRLocale,
                          firstDate: Jalali(1350),
                          lastDate: Jalali.now(),
                        );
                        if (!context.mounted || date == null) {
                          return;
                        }
                        final queryString = Helpers.jalaliToDashDate(date);
                        Helpers.addQueryToPath(
                          context,
                          "fromDate",
                          queryString,
                        );
                        value.setFromDate(date);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: localizations.removeFilter,
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      disabledColor: Colors.grey,
                      onPressed:
                          toDate == null
                              ? null
                              : () {
                                Helpers.removeQueryFromPath(context, "toDate");
                                value.setToDate(null);
                                setState(() {});
                              },
                    ),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        constraints: BoxConstraints.loose(
                          Size(300, double.infinity),
                        ),
                        labelText: localizations.toDate,
                        hintText: localizations.toDate,
                      ),
                      controller: _toDateController,
                      onTap: () async {
                        final date = await showPersianDatePicker(
                          context: context,
                          locale: Preferences.persianIRLocale,
                          firstDate: Jalali(1350),
                          lastDate: Jalali.now(),
                        );
                        if (!context.mounted || date == null) {
                          return;
                        }
                        final queryString = Helpers.jalaliToDashDate(date);
                        Helpers.addQueryToPath(context, "toDate", queryString);
                        value.setToDate(date);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }
}
