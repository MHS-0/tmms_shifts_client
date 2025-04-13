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
    _fromDate = date;
    notifyListeners();
  }

  void setToDate(Jalali? date) {
    _toDate = date;
    notifyListeners();
  }
}
