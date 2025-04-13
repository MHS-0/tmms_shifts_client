import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class DatePickerProvider extends ChangeNotifier {
  Jalali? get fromDate => _fromDate;
  Jalali? get toDate => _toDate;

  Jalali? _fromDate;
  Jalali? _toDate;

  DatePickerProvider({Jalali? fromDateParam, Jalali? toDateParam})
    : _fromDate = fromDateParam,
      _toDate = toDateParam;

  void setFromDate(Jalali? date) {
    setFromDateNoStateUpdate(date);
    notifyListeners();
  }

  void setFromDateNoStateUpdate(Jalali? date) {
    _fromDate = date;
  }

  void setToDate(Jalali? date) {
    setToDateNoStateUpdate(date);
    notifyListeners();
  }

  void setToDateNoStateUpdate(Jalali? date) {
    _toDate = date;
  }
}
