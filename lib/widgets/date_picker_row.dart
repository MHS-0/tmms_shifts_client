import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
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
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final datePickerState = context.watch<DatePickerProvider>();
    final fromDate = datePickerState.fromDate;
    final toDate = datePickerState.toDate;
    _fromDateController.text = fromDate?.formatCompactDate() ?? "";
    _toDateController.text = toDate?.formatCompactDate() ?? "";

    return Center(
      child: Padding(
        padding: offsetAll32p,
        child: Wrap(
          spacing: 64,
          runSpacing: 16,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 16,
              children: [
                IconButton(
                  tooltip: localizations.removeFilter,
                  icon: trashcanIcon,
                  color: Colors.red,
                  disabledColor: Colors.grey,
                  onPressed:
                      fromDate == null
                          ? null
                          : () {
                            final date = Jalali.now().addDays(-1);
                            final dateString = Helpers.jalaliToDashDate(date);
                            datePickerState.setFromDate(date);
                            Helpers.addQueryToPath(
                              context,
                              fromDateKey,
                              dateString,
                            );
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
                      lastDate: toDate ?? Jalali.now(),
                    );
                    if (!context.mounted || date == null) {
                      return;
                    }
                    final queryString = Helpers.jalaliToDashDate(date);
                    datePickerState.setFromDate(date);
                    Helpers.addQueryToPath(context, fromDateKey, queryString);
                  },
                ),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 16,
              children: [
                IconButton(
                  tooltip: localizations.removeFilter,
                  icon: trashcanIcon,
                  color: Colors.red,
                  disabledColor: Colors.grey,
                  onPressed:
                      toDate == null
                          ? null
                          : () {
                            final date = Jalali.now();
                            final dateString = Helpers.jalaliToDashDate(date);
                            datePickerState.setToDate(date);
                            Helpers.addQueryToPath(
                              context,
                              toDateKey,
                              dateString,
                            );
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
                      firstDate: fromDate ?? jalaliFirstAcceptableDate,
                      lastDate: Jalali.now(),
                    );
                    if (!context.mounted || date == null) {
                      return;
                    }
                    final queryString = Helpers.jalaliToDashDate(date);
                    datePickerState.setToDate(date);
                    Helpers.addQueryToPath(context, toDateKey, queryString);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }
}
