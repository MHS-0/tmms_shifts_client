import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

class DatePickerSingleField extends StatefulWidget {
  final bool center;

  const DatePickerSingleField({super.key, this.center = false});

  @override
  State<DatePickerSingleField> createState() => _DatePickerSingleFieldState();
}

class _DatePickerSingleFieldState extends State<DatePickerSingleField> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final datePickerState = context.watch<DatePickerProvider>();

    _textController.text = datePickerState.reportDate.formatCompactDate();

    return Helpers.titleAndWidgetRow(
      "${localizations.date} :",
      TextField(
        readOnly: true,
        decoration: InputDecoration(
          constraints: BoxConstraints.loose(Size(200, double.infinity)),
          labelText: localizations.date,
          hintText: localizations.date,
        ),
        controller: _textController,
        onTap: () async {
          final date = await showPersianDatePicker(
            context: context,
            locale: Preferences.persianIRLocale,
            firstDate: Jalali(1400),
            lastDate: Jalali.now(),
            initialDate: Jalali.now(),
          );
          if (!context.mounted || date == null) {
            return;
          }
          datePickerState.setReportDate(date);
        },
      ),
      width: 200,
      center: widget.center,
      titleWidth: widget.center ? 100 : 200,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
